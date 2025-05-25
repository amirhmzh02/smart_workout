<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

require 'connection.php';  // Ensure this sets $pdo correctly

$input = json_decode(file_get_contents("php://input"), true);

// Validate required fields
if (
    empty($input['user_id']) ||
    empty($input['name']) ||
    empty($input['age']) ||
    empty($input['weight']) ||
    empty($input['height']) ||
    empty($input['gender'])
) {
    echo json_encode([
        'success' => false,
        'message' => 'Missing required fields'
    ]);
    exit;
}

$minCalories = isset($input['min_calories']) ? $input['min_calories'] : null;
$maxCalories = isset($input['max_calories']) ? $input['max_calories'] : null;
$fitnessGoal = isset($input['fitness_goal']) ? $input['fitness_goal'] : null;

try {
    // Build dynamic SQL
    $stmt = $pdo->prepare("
        UPDATE user 
        SET 
            name = :name, 
            age = :age, 
            weight = :weight, 
            height = :height, 
            gender = :gender,
            fitness_goal = :fitness_goal
        WHERE user_id = :user_id
    ");

    $stmt->execute([
        ':user_id' => $input['user_id'],
        ':name' => $input['name'],
        ':age' => $input['age'],
        ':weight' => $input['weight'],
        ':height' => $input['height'],
        ':gender' => $input['gender'],
        ':fitness_goal' => $fitnessGoal
    ]);

    echo json_encode([
        'success' => true,
        'message' => 'User info updated successfully'
    ]);

    // Insert dietary plan
    $planName = $fitnessGoal;  // same as goal
    $createdDate = date("Y-m-d");

    $stmt2 = $pdo->prepare("
    INSERT INTO dietaryplan (user_id, plan_name, min_calories_per_day, max_calories_per_day, created_date) 
    VALUES (:user_id, :plan_name, :min_cal, :max_cal, :created_date)
");

    $stmt2->execute([
        ':user_id' => $input['user_id'],
        ':plan_name' => $planName,
        ':min_cal' => $minCalories,
        ':max_cal' => $maxCalories,
        ':created_date' => $createdDate
    ]);

} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ]);
}
