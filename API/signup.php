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

$email = filter_var($input['email'], FILTER_SANITIZE_EMAIL);
$password = $input['password'];

try {
    // Check if email already exists
    $checkStmt = $pdo->prepare("SELECT user_id FROM user WHERE email = :email");
    $checkStmt->execute([':email' => $email]);

    if ($checkStmt->fetch()) {
        echo json_encode([
            'success' => false,
            'message' => 'Email already in use'
        ]);
        exit;
    }

    // Insert new user
    $insertStmt = $pdo->prepare("INSERT INTO user (email, password) VALUES (:email, :password)");
    $insertStmt->execute([
        ':email' => $email,
        ':password' => $password // You can hash this with password_hash() for security
    ]);

    echo json_encode([
        'success' => true,
        'message' => 'Account created successfully'
    ]);
    http_response_code(201); // Created
} catch (PDOException $e) {
    error_log("Signup error: " . $e->getMessage());
    echo json_encode([
        'success' => false,
        'message' => 'Server error'
    ]);
}
