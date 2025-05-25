<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");
require 'connection.php';

$input = json_decode(file_get_contents('php://input'), true);

// Input validation
if (empty($input['email']) || empty($input['password'])) {
    die(json_encode(['success' => false, 'message' => 'Missing credentials']));
}

try {
    $stmt = $pdo->prepare("
        SELECT user_id 
        FROM user 
        WHERE email = :email 
        AND password = :password
        LIMIT 1
    ");
    
    $stmt->execute([
        ':email' => filter_var($input['email'], FILTER_SANITIZE_EMAIL),
        ':password' => $input['password']  // Fixed the typo here
    ]);

    if ($user = $stmt->fetch()) {
        echo json_encode([
            'success' => true,
            'user_id' => $user['user_id'],  // Changed from 'id' to 'user_id' to match your query
            'token' => bin2hex(random_bytes(16))
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Invalid credentials'
        ]);
    }
} catch (PDOException $e) {
    error_log("Database error: " . $e->getMessage());
    echo json_encode([
        'success' => false,
        'message' => 'Server error'
    ]);
}