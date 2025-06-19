
<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");
require 'connection.php'; // must define $pdo (PDO connection)

$input = json_decode(file_get_contents('php://input'), true);

$user_id = $input['user_id'] ?? null;
$month = $input['month'] ?? null;

if (!$user_id || !$month) {
    echo json_encode(['success' => false, 'message' => 'Missing user_id or month']);
    exit;
}

$sql = "
    SELECT 
        DATE(date) AS full_date,
        DATE_FORMAT(date, '%d %M') AS date,
        SUM(calc_burn) AS calories
    FROM workout_done
    WHERE user_id = ?
      AND DATE_FORMAT(date, '%Y-%m') = ?
    GROUP BY DATE(date)
    ORDER BY DATE(date) DESC
";

try {
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$user_id, $month]);
    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode(['success' => true, 'diary_entries' => $data]);
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Database error',
        'error' => $e->getMessage()
    ]);
}
