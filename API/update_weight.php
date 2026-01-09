<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");
require 'connection.php';

try {
    $input = json_decode(file_get_contents("php://input"), true);
    $userId = $input['user_id'] ?? null;
    $weight = $input['weight'] ?? null;
    $date = $input['date'] ?? date('Y-m-d');

    if (!$userId || !$weight) {
        echo json_encode([
            'success' => false,
            'message' => 'Missing required fields: user_id or weight'
        ]);
        exit;
    }

    // Check if weight already updated for the same date
    $checkStmt = $pdo->prepare("SELECT COUNT(*) FROM progresstracking WHERE user_id = :user_id AND date = :date");
    $checkStmt->execute([
        ':user_id' => $userId,
        ':date' => $date
    ]);

    if ($checkStmt->fetchColumn() > 0) {
        echo json_encode([
            'success' => false,
            'message' => 'Weight already updated for today'
        ]);
        exit;
    }


    // Insert into progresstracking
    $stmt = $pdo->prepare("INSERT INTO progresstracking (user_id, date, weight) VALUES (:user_id, :date, :weight)");
    $stmt->execute([
        ':user_id' => $userId,
        ':date' => $date,
        ':weight' => $weight
    ]);

    // Get user profile for calorie calculation (assumes these fields are in your user table)
    $userStmt = $pdo->prepare("SELECT height, age, gender FROM user WHERE user_id = :user_id");
    $userStmt->execute([':user_id' => $userId]);
    $user = $userStmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        echo json_encode(['success' => false, 'message' => 'User not found']);
        exit;
    }
    $activityLevel = isset($user['activity_level']) ? intval($user['activity_level']) : 4;


    // Call the Python API to get calorie range
    $bmiPayload = json_encode([
        'weight' => floatval($weight),
        'height' => floatval($user['height']),
        'age' => intval($user['age']),
        'gender' => intval($user['gender']),
        'activity_level' => $activityLevel
    ]);

//     echo json_encode([
//     'success' => true,
//     'bmiPayload' => json_decode($bmiPayload) // Pretty print in JSON
// ]);
// exit;

    $ch = curl_init('https://walkerz.pythonanywhere.com/bmi');
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $bmiPayload);

    $bmiResponse = curl_exec($ch);
    curl_close($ch);

    $bmiData = json_decode($bmiResponse, true);

    if (!$bmiData || !isset($bmiData['calories']['range'])) {
        echo json_encode([
            'success' => false,
            'message' => 'Failed to get calorie range from BMI API',
            'bmiResponse' => $bmiResponse
        ]);
        exit;
    }

    $minCal = $bmiData['calories']['range'][0];
    $maxCal = $bmiData['calories']['range'][1];

    // Update dietaryplan for this user
    $dietStmt = $pdo->prepare("
    UPDATE dietaryplan 
    SET 
        min_calories_per_day = :minCal, 
        max_calories_per_day = :maxCal 
    WHERE user_id = :user_id
");

$dietStmt->execute([
    ':minCal' => $minCal,
    ':maxCal' => $maxCal,
    ':user_id' => $userId
]);



    echo json_encode([
        'success' => true,
        'message' => 'Weight and calorie range updated successfully',
        'min_calories' => $minCal,
        'max_calories' => $maxCal
    ]);
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Database error',
        'error' => $e->getMessage()
    ]);
}
