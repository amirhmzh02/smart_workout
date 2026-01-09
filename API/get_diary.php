<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");
require 'connection.php';

$input = json_decode(file_get_contents('php://input'), true);
$userId = $input['user_id'] ?? null;
$month = $input['month'] ?? date('m');
$year = $input['year'] ?? date('Y');

if (!$userId) {
    echo json_encode(['success' => false, 'message' => 'User ID missing']);
    exit;
}

try {
    $stmt = $pdo->prepare("
        SELECT diary_id, user_id, meal_type, meal_name, ingredients, calories, date 
        FROM diary 
        WHERE user_id = ? 
        AND MONTH(date) = ?
        AND YEAR(date) = ?
        ORDER BY date DESC
    ");
    $stmt->execute([$userId, $month, $year]);
    $diaryEntries = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($diaryEntries) {
        echo json_encode(['success' => true, 'diary_entries' => $diaryEntries]);
    } else {
        echo json_encode(['success' => true, 'diary_entries' => [], 'message' => 'No diary entries found for selected month']);
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Query failed', 'error' => $e->getMessage()]);
}
?>