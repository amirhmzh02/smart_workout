<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");
require 'connection.php';

$input = json_decode(file_get_contents('php://input'), true);
$userId = $input['user_id'] ?? null;
$daysPerWeek = $input['days_per_week'] ?? null;
$equipmentHave = $input['equipment_have'] ?? [];

if (!$userId || !$daysPerWeek) {
    echo json_encode(['success' => false, 'message' => 'Missing required fields']);
    exit;
}

try {
    // Convert equipment list to JSON string
    $equipmentJson = json_encode($equipmentHave);
    
    // Check if user already has a workout plan
    $checkStmt = $pdo->prepare("SELECT workout_id FROM workoutplan WHERE user_id = ?");
    $checkStmt->execute([$userId]);
    
    if ($checkStmt->rowCount() > 0) {
        // Update existing plan
        $stmt = $pdo->prepare("
            UPDATE workoutplan 
            SET day_per_week = ?, 
                equipment_have = ?
            WHERE user_id = ?
        ");
        $success = $stmt->execute([$daysPerWeek, $equipmentJson, $userId]);
    } else {
        // Insert new plan
        $stmt = $pdo->prepare("
            INSERT INTO workoutplan 
            (user_id, day_per_week, equipment_have) 
            VALUES (?, ?, ?)
        ");
        $success = $stmt->execute([$userId, $daysPerWeek, $equipmentJson]);
    }

    echo json_encode([
        'success' => $success,
        'message' => $success ? 'Workout plan saved' : 'Failed to save workout plan'
    ]);
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Database error',
        'error' => $e->getMessage()
    ]);
}
?>