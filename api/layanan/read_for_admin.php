<?php
include "../db_connect.php";

// Set response header to JSON
header('Content-Type: application/json');

try {
    // Prepare statement
    $query = $conn->prepare("SELECT * FROM poliklinik");

    // Execute statement
    $query->execute();

    // Get result
    $result = $query->get_result();

    // Check for successful retrieval of data
    if ($result) {
        $data = $result->fetch_all(MYSQLI_ASSOC);
        echo json_encode($data, JSON_PRETTY_PRINT); // Use pretty print for better readability
    } else {
        echo json_encode([
            'status' => 'error',
            'message' => 'Query failed: ' . $conn->error
        ]);
    }

    // Close statement and connection
    $query->close();
    $conn->close();
} catch (Exception $e) {
    echo json_encode([
        'status' => 'error',
        'message' => 'An error occurred: ' . $e->getMessage()
    ]);
}
?>
