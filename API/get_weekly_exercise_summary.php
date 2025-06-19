<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

require 'connection.php';

$input = json_decode(file_get_contents('php://input'), true);
$userId = $input['user_id'] ?? null;

if (!$userId) {
    echo json_encode(['success' => false, 'message' => 'User ID missing']);
    exit;
}

try {
    $stmt = $pdo->prepare("
        SELECT 
            COUNT(*) AS total_exercises,
            COUNT(DISTINCT date) AS total_days,
            SUM(calc_burn) AS total_calories,
            MIN(date) AS from_date,
            MAX(date) AS to_date
        FROM workout_done
        WHERE user_id = ? AND YEARWEEK(date, 1) = YEARWEEK(CURDATE(), 1)
    ");

    $stmt->execute([$userId]);
    $summary = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($summary && $summary['total_exercises'] > 0) {
        echo json_encode(['success' => true, 'data' => $summary]);
    } else {
        echo json_encode(['success' => false, 'message' => 'No exercise data for this week']);
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Query failed', 'error' => $e->getMessage()]);
}
?>
