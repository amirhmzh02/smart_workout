<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");
require 'connection.php';

// Get muscle group from query parameter
$muscleGroup = $_GET['muscle_group'] ?? null;

if (!$muscleGroup) {
    echo json_encode(['success' => false, 'message' => 'Muscle group parameter is required']);
    exit;
}

try {
    $stmt = $pdo->prepare("
        SELECT `exercise_id`, `muscle_groups`, `exercise_name`, `description`, 
               `tutorial`, `tutorial_video`, `equipment_need` 
        FROM `exercise` 
        WHERE `muscle_groups` LIKE ?
    ");
    
    // Using LIKE with wildcards to match partial group names
    $stmt->execute(["%$muscleGroup%"]);
    $exercises = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'data' => $exercises,
        'message' => count($exercises) ? 'Exercises found' : 'No exercises for this muscle group'
    ]);
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Database error',
        'error' => $e->getMessage()
    ]);
}
?>