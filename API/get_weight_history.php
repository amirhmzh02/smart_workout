<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");
require 'connection.php';

$input = json_decode(file_get_contents('php://input'), true);
$userId = $input['user_id'] ?? null;

if (!$userId) {
    echo json_encode(['success' => false, 'message' => 'User ID required']);
    exit;
}

try {
    $stmt = $pdo->prepare("
        SELECT date, weight 
        FROM progresstracking 
        WHERE user_id = ? 
        AND weight IS NOT NULL
        ORDER BY date ASC
    ");
    $stmt->execute([$userId]);
    $weights = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'data' => $weights,
        'message' => count($weights) ? 'Weight data found' : 'No weight data'
    ]);
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Database error',
        'error' => $e->getMessage()
    ]);
}
?>