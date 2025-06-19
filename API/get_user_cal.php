<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");
require 'connection.php';

// Get JSON input
$input = json_decode(file_get_contents('php://input'), true);
$userId = $input['user_id'] ?? null;

if (!$userId) {
    echo json_encode(['success' => false, 'message' => 'User ID missing']);
    exit;
}

try {
    $stmt = $pdo->prepare("SELECT min_calories_per_day, max_calories_per_day FROM dietaryplan WHERE user_id = ?");
    $stmt->execute([$userId]);
    $calorieData = $stmt->fetch();

    if ($calorieData) {
        echo json_encode(['success' => true, 'data' => $calorieData]);
    } else {
        echo json_encode(['success' => false, 'message' => 'No data found for user']);
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Query failed', 'error' => $e->getMessage()]);
}
?>
