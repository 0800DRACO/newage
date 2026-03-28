<?php

// Prevent direct access issues
define('LARAVEL_START', microtime(true));

// Check if .env file exists
$envPath = dirname(__DIR__) . '/.env';
if (!file_exists($envPath)) {
    http_response_code(500);
    die('Environment file not found. Please check your deployment.');
}

try {
    // Load Laravel
    require dirname(__DIR__) . '/vendor/autoload.php';
    
    $app = require_once dirname(__DIR__) . '/bootstrap/app.php';
    
    $kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
    
    $response = $kernel->handle(
        $request = Illuminate\Http\Request::capture()
    );
    
    $response->send();
    
    $kernel->terminate($request, $response);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'error' => 'Application Error',
        'message' => $e->getMessage(),
        'environment' => getenv('APP_ENV')
    ]);
}
