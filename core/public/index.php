<?php

// Prevent direct access issues
if (!defined('LARAVEL_START')) {
    define('LARAVEL_START', microtime(true));
}

error_reporting(E_ALL);
ini_set('display_errors', 'Off');

$envPath = dirname(__DIR__) . '/.env';

try {
    // Check if .env file exists
    if (!file_exists($envPath)) {
        throw new RuntimeException('Environment file not found at: ' . $envPath);
    }

    // Verify autoloader exists
    $autoloadPath = dirname(__DIR__) . '/vendor/autoload.php';
    if (!file_exists($autoloadPath)) {
        throw new RuntimeException('Composer autoloader not found at: ' . $autoloadPath);
    }

    // Load Laravel
    require $autoloadPath;
    
    $bootstrapPath = dirname(__DIR__) . '/bootstrap/app.php';
    if (!file_exists($bootstrapPath)) {
        throw new RuntimeException('Laravel bootstrap file not found at: ' . $bootstrapPath);
    }
    
    $app = require_once $bootstrapPath;
    
    $kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
    
    $response = $kernel->handle(
        $request = Illuminate\Http\Request::capture()
    );
    
    $response->send();
    
    $kernel->terminate($request, $response);
    
} catch (Throwable $e) {
    http_response_code(500);
    
    $error = [
        'error' => get_class($e),
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
        'environment' => getenv('APP_ENV') ?: 'unknown',
        'timestamp' => date('c'),
    ];
    
    // Log to stderr for DigitalOcean
    error_log('Application Error: ' . json_encode($error));
    
    header('Content-Type: application/json; charset=UTF-8');
    echo json_encode($error, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
    exit(1);
}
