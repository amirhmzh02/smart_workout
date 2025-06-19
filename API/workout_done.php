<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");
require 'connection.php';

// Read raw POST data
$input = json_decode(file_get_contents('php://input'), true);
if (!isset($input['data']) || !is_array($input['data'])) {
    echo json_encode(['success' => false, 'message' => 'Invalid input data']);
    exit;
}

try {
    foreach ($input['data'] as $item) {
        $userId = $item['user_id'] ?? null;
        $exerciseId = $item['exercise_id'] ?? null;
        $sets = $item['sets'] ?? 0;
        $reps = $item['reps'] ?? 0;
        $date = $item['date'] ?? date('Y-m-d');

        if (!$userId || !$exerciseId || !$sets || !$reps) {
            continue; // Skip invalid item
        }

        // Get latest weight for the user
        $weightStmt = $pdo->prepare("SELECT weight FROM progresstracking WHERE user_id = ? ORDER BY date DESC LIMIT 1");
        $weightStmt->execute([$userId]);
        $userWeight = $weightStmt->fetchColumn();
        if (!$userWeight) {
            $userWeight = 60; // default weight if not found
        }

        // Get MET value of the exercise
        $metStmt = $pdo->prepare("SELECT met_value FROM exercise WHERE exercise_id = ?");
        $metStmt->execute([$exerciseId]);
        $metValue = $metStmt->fetchColumn();
        if (!$metValue) {
            $metValue = 3.0; // default MET if not found
        }

        // ⏱ Estimate total duration in minutes (assuming 3 sec per rep)
        $avgTimePerRepSec = 3;
        $restTimePerSet = 60;

        $totalReps = $sets * $reps;
        $exerciseTime = $totalReps * $avgTimePerRepSec;
        $restTime = ($sets - 1) * $restTimePerSet;

        $totalSeconds = $exerciseTime + $restTime;
        $durationInMinutes = $totalSeconds / 60;

        // 🔥 Calculate calories burned using MET formula
        $caloriesBurned = 0.0175 * $metValue * $userWeight * $durationInMinutes;

        // Insert into workout_done table
        $insertStmt = $pdo->prepare("
            INSERT INTO workout_done (user_id, exercise_id, `set`, rep, calc_burn, `date`)
            VALUES (?, ?, ?, ?, ?, ?)
        ");
        $insertStmt->execute([
            $userId,
            $exerciseId,
            $sets,
            $reps,
            round($caloriesBurned, 2),
            $date
        ]);
    }

    echo json_encode(['success' => true, 'message' => 'Workout data inserted successfully']);
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Server error',
        'error' => $e->getMessage()
    ]);
}
?>
