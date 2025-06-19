<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
require_once 'connection.php';

$data = json_decode(file_get_contents('php://input'), true);

try {
    // Start transaction
    $pdo->beginTransaction();

    // Validate input
    if (!isset($data['diary_entries']) || !is_array($data['diary_entries'])) {
        throw new Exception("Invalid input: 'diary_entries' is missing or not an array");
    }

    // Prepare statement (UPDATED: include calories)
    $stmt = $pdo->prepare("
        INSERT INTO diary (user_id,meal_type,meal_name,ingredients, calories, date)
        VALUES (?, ?, ?,?, ?,?)
    ");

    // Insert all entries
    foreach ($data['diary_entries'] as $entry) {
        if (!isset($entry['user_id'], /*$entry['meal_id'],*/$entry['meal_type'],$entry['meal_name'], $entry['ingredients'], $entry['calories'], $entry['date'])) {
            continue; // Skip if missing fields
        }

        $stmt->execute([
            $entry['user_id'],
            // $entry['meal_id'],
            $entry['meal_type'],
            $entry['meal_name'],
            $entry['ingredients'],
            $entry['calories'],
            $entry['date']
        ]);
    }

    $pdo->commit();

    echo json_encode(['success' => true, 'message' => 'Diary entries saved successfully']);

} catch (Exception $e) {
    $pdo->rollBack();
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
