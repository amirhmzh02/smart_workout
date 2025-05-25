<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
require_once 'connection.php';

// Enable error logging
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Get search query from request
$search = $_GET['search'] ?? '';

try {
    if (!empty($search)) {
        // Search with query
        $stmt = $pdo->prepare("
            SELECT `ingredient_id`, `ingredient_name`, `calories` 
            FROM `ingredient`
            WHERE `ingredient_name` LIKE CONCAT('%', ?, '%')
            LIMIT 20
        ");
        $stmt->execute([$search]);
    } else {
        // Return all ingredients if no search query
        $stmt = $pdo->prepare("
            SELECT `ingredient_id`, `ingredient_name`, `calories` 
            FROM `ingredient`
            LIMIT 20
        ");
        $stmt->execute();
    }

    $ingredients = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'data' => $ingredients
    ]);

} catch (Exception $e) {
    error_log("ERROR: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}