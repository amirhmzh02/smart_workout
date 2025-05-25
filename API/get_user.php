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
    $stmt = $pdo->prepare("SELECT name, age, weight, height, gender, fitness_goal, email FROM user WHERE user_id = ?");
    $stmt->execute([$userId]);  // Pass userId as an array
    $userData = $stmt->fetch();

    if ($userData) {
        echo json_encode(['success' => true, 'user' => $userData]);
    } else {
        echo json_encode(['success' => false, 'message' => 'User not found']);
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Query failed', 'error' => $e->getMessage()]);
}
?>
