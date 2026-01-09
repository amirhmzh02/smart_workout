<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");
require 'connection.php';

$userId = $_GET['user_id'] ?? null;
$location = $_GET['location'] ?? 'home';
$today = isset($_GET['day']) ? intval($_GET['day']) : (date('N') - 1); // 0 = Monday

if (!$userId) {
    echo json_encode(['success' => false, 'message' => 'User ID missing']);
    exit;
}

try {
    // Get user workout plan
    $stmt = $pdo->prepare("SELECT day_per_week, equipment_have FROM workoutplan WHERE user_id = ?");
    $stmt->execute([$userId]);
    $plan = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$plan) {
        echo json_encode(['success' => false, 'message' => 'Workout plan not found']);
        exit;
    }

    $days = (int)$plan['day_per_week'];
    $userEquipment = array_map('trim', explode(',', strtolower($plan['equipment_have'] ?? '')));
    $equipmentSet = array_filter($userEquipment);

    // Muscle targets per day
    $daySplits = [
    3 => [
        ['chest','back','shoulder','tricep','bicep'], // Day 1: Workout
        ['rest'],                                     // Day 2: Rest
        ['leg','core'],                               // Day 3: Workout
        ['rest'],                                     // Day 4: Rest
        ['chest','back','leg','core']                 // Day 5: Workout
    ],
    4 => [
        ['chest','shoulder','tricep'],
        ['back','bicep'],
        ['rest'],
        ['leg','core'],
        ['chest','back','shoulder'],
    ],
    5 => [
        ['chest','shoulder','tricep'],
        ['back','bicep'],
        ['leg'],
        ['core','chest','shoulder'],
        ['leg','core']
    ]
];


    // Rest day handling
    if ($today >= 5 || !isset($daySplits[$days][$today])) {
        echo json_encode(['success' => true, 'exercises' => [], 'message' => 'Rest day or invalid']);
        exit;
    }

    $targetMuscles = $daySplits[$days][$today];
    if (in_array('rest', $targetMuscles)) {
    echo json_encode([
        'success' => true,
        'exercises' => [],
        'workout_day' => $today + 1,
        'total_days' => $days,
        'target_muscles' => [],
        'recommended_count' => 0,
        'actual_count' => 0,
        'message' => 'Rest day'
    ]);
    exit;
}

    // Recommended number of exercises
    $recommendedCount = match ($days) {
        3 => 8,
        4 => 6,
        5 => 5,
        default => 6
    };

    // SQL to get valid exercises (match muscle group + filter by equipment/location)
    $placeholders = implode(',', array_fill(0, count($targetMuscles), '?'));
    $muscleParams = $targetMuscles;

    $sql = "
        SELECT e.*
        FROM exercise e
        JOIN exercise_muscle em ON e.exercise_id = em.exercise_id
        WHERE em.muscle_group IN ($placeholders)
        GROUP BY e.exercise_id
    ";
    $stmt = $pdo->prepare($sql);
    $stmt->execute($muscleParams);
    $allExercises = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Filter based on location/equipment
    $qualifiedExercises = [];
    foreach ($allExercises as $exercise) {
        $requiredEquip = array_map('trim', explode(',', strtolower($exercise['equipment_need'])));

        if ($location === 'home') {
            if (in_array('none', $requiredEquip) || count(array_intersect($requiredEquip, $equipmentSet)) > 0) {
                $qualifiedExercises[] = $exercise;
            }
        } else {
            // Gym: assume all equipment is available
            $qualifiedExercises[] = $exercise;
        }

    }

    // Shuffle and limit the result
    shuffle($qualifiedExercises);
    $finalList = array_slice($qualifiedExercises, 0, $recommendedCount);

    echo json_encode([
        'success' => true,
        'exercises' => $finalList,
        'workout_day' => $today + 1,
        'total_days' => $days,
        'target_muscles' => $targetMuscles,
        'recommended_count' => $recommendedCount,
        'actual_count' => count($finalList)
    ]);

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Server error',
        'error' => $e->getMessage()
    ]);
}
