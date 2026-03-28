<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'message' => 'RealVest Payment Gateway API',
        'version' => '1.0.0',
        'status' => 'operational',
    ]);
});

Route::get('/health', function () {
    return response()->json(['status' => 'healthy']);
});

Route::get('/up', function () {
    return 'OK';
});
