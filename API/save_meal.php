<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
require_once 'connection.php';

$data = json_decode(file_get_contents('php://input'), true);

try {
    // Start transaction
    $pdo->beginTransaction();
    
    // 1. Insert the meal
    $stmt = $pdo->prepare("
        INSERT INTO meal (meal_name, meal_type, calories, is_custom)
        VALUES (?, ?, ?, 1)
    ");
    $stmt->execute([
        $data['name'],
        $data['meal_type'] ?? 'custom', // You might want to pass meal type from frontend
        $data['calories']
    ]);
    $mealId = $pdo->lastInsertId();
    
    // 2. Insert meal ingredients with custom quantities
    $stmt = $pdo->prepare("
        INSERT INTO meal_ingredient (meal_id, ingredient_id, quantity)
        VALUES (?, ?, ?)
    ");
    
    foreach ($data['ingredients'] as $ingredient) {
        $stmt->execute([
            $mealId,
            $ingredient['ingredient_id'],
            $ingredient['quantity']
        ]);
    }
    
    $pdo->commit();
    
    echo json_encode(['success' => true, 'meal_id' => $mealId]);
    
} catch (Exception $e) {
    $pdo->rollBack();
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}