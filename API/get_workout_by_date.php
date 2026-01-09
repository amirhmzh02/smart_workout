<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

require 'connection.php'; // This defines $pdo

$input = json_decode(file_get_contents("php://input"), true);

// Read user_id and date from input
$user_id = $input['user_id'] ?? null;
$date = $input['date'] ?? null;

if (!$user_id || !$date) {
    echo json_encode([
        "success" => false,
        "message" => "User ID and date are required."
    ]);
    exit;
}

try {
    $stmt = $pdo->prepare("
        SELECT 
            wd.wkid,
            wd.exercise_id,
            e.exercise_name,
            e.description,
            wd.set,
            wd.rep,
            wd.calc_burn
        FROM workout_done wd
        INNER JOIN exercise e ON wd.exercise_id = e.exercise_id
        WHERE wd.user_id = ? AND wd.date = ?
        ORDER BY wd.wkid DESC
    ");

    $stmt->execute([$user_id, $date]);
    $workouts = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "success" => true,
        "data" => $workouts
    ]);

} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Database error",
        "error" => $e->getMessage()
    ]);
}
?>
