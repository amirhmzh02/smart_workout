<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");
require 'connection.php';

$input = json_decode(file_get_contents('php://input'), true);
$userId = $input['user_id'] ?? null;

if (!$userId) {
    echo json_encode(['success' => false, 'message' => 'Missing user ID']);
    exit;
}

try {
    $stmt = $pdo->prepare("SELECT workout_id FROM workoutplan WHERE user_id = ?");
    $stmt->execute([$userId]);

    if ($stmt->rowCount() > 0) {
        echo json_encode(['success' => true, 'hasPlan' => true]);
    } else {
        echo json_encode(['success' => true, 'hasPlan' => false]);
    }
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Database error',
        'error' => $e->getMessage()
    ]);
}
?>
