<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return [
        'message' => 'RealVest Payment Gateway API',
        'version' => '1.0.0',
        'status' => 'operational',
    ];
});

Route::get('/up', function () {
    return 'OK';
});
