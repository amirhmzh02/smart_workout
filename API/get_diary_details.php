<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");
require 'connection.php';

$input = json_decode(file_get_contents('php://input'), true);
$userId = $input['user_id'] ?? null;
$date = $input['date'] ?? null;

if (!$userId || !$date) {
    echo json_encode(['success' => false, 'message' => 'Missing parameters']);
    exit;
}

try {
    $stmt = $pdo->prepare("
        SELECT diary_id, user_id, meal_type, meal_name, ingredients, calories, date 
        FROM diary 
        WHERE user_id = ? AND date = ?
        ORDER BY meal_type
    ");
    $stmt->execute([$userId, $date]);
    $meals = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'meals' => $meals ?: [],
        'message' => $meals ? 'Meals found' : 'No meals for this date'
    ]);
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Query failed',
        'error' => $e->getMessage()
    ]);
}
?>