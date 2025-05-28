<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
require_once 'connection.php';

// Enable error logging
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Get user ID from request
$userId = $_GET['user_id'] ?? null;

if (!$userId || !is_numeric($userId)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid user ID']);
    exit();
}

try {
    // 1. Get user's dietary plan
    $stmt = $pdo->prepare("
        SELECT min_calories_per_day, max_calories_per_day 
        FROM dietaryplan 
        WHERE user_id = ? 
        ORDER BY created_date DESC 
        LIMIT 1
    ");
    $stmt->execute([$userId]);
    $dietPlan = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$dietPlan) {
        throw new Exception("No dietary plan found for user $userId");
    }

    $minCalories = (int) $dietPlan['min_calories_per_day'];
    $maxCalories = (int) $dietPlan['max_calories_per_day'];
    $targetCalories = ($minCalories + $maxCalories) / 2;

    error_log("User $userId | Target calories: $targetCalories (Min: $minCalories, Max: $maxCalories)");

    // 2. Generate meal plan
    $mealTypes = ['breakfast', 'mid_morning', 'lunch', 'dinner', 'snack'];
    $calorieDistribution = [
        'breakfast' => 0.25,
        'mid_morning' => 0.15,
        'lunch' => 0.35,
        'dinner' => 0.30,
        'snack' => 0.10
    ];

    $mealPlan = [];

    foreach ($mealTypes as $type) {
        $target = (int) ($targetCalories * $calorieDistribution[$type]);
        $lower = (int) ($target * 0.7);  // 30% below target
        $upper = (int) ($target * 1.3);  // 30% above target

        error_log("Searching $type meals | Target: $target | Range: $lower-$upper");

        // First try to find meal in ideal range
        $stmt = $pdo->prepare("
            SELECT m.* 
            FROM meal m
            WHERE m.meal_type = ? 
            AND m.calories BETWEEN ? AND ?
            ORDER BY RAND()
            LIMIT 1
        ");
        $stmt->execute([$type, $lower, $upper]);
        $meal = $stmt->fetch(PDO::FETCH_ASSOC);

        // Fallback to closest calorie match if none found
        if (!$meal) {
            error_log("No $type meal found in range $lower-$upper, using fallback");
            $stmt = $pdo->prepare("
                SELECT m.* 
                FROM meal m
                WHERE m.meal_type = ?
                ORDER BY ABS(m.calories - ?)
                LIMIT 1
            ");
            $stmt->execute([$type, $target]);
            $meal = $stmt->fetch(PDO::FETCH_ASSOC);
        }

        if ($meal) {
            // Get ingredients
            $stmt = $pdo->prepare("
                SELECT i.ingredient_id, i.ingredient_name, mi.quantity 
FROM meal_ingredient mi
JOIN ingredient i ON mi.ingredient_id = i.ingredient_id
WHERE mi.meal_id = ?;

            ");
            $stmt->execute([$meal['meal_id']]);
            $ingredients = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // Format ingredients
            $ingredientList = array_map(function ($ing) {
                return round($ing['quantity'], 2) . 'g ' . $ing['ingredient_name'];
            }, $ingredients);

            $ingredientIdList = array_map(function ($ing) {
                return $ing['ingredient_id'];  // or use actual ID if needed
            }, $ingredients);

            $mealPlan[] = [
                'meal_id' => $meal['meal_id'],
                'meal_type' => ucfirst($meal['meal_type']),
                'name' => $meal['meal_name'],
                'calories' => $meal['calories'] . ' kcal',
                'ingredients' => $ingredientList,
                'ingredients_id' => $ingredientIdList // Add this line
            ];


            error_log("Added $type meal: {$meal['meal_name']} ({$meal['calories']} kcal)");
        } else {
            error_log("No $type meals available in database");
        }
    }

    if (empty($mealPlan)) {
        throw new Exception("No meals could be generated for this plan");
    }

    echo json_encode([
        'success' => true,
        'data' => $mealPlan
    ]);

} catch (Exception $e) {
    error_log("ERROR: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}