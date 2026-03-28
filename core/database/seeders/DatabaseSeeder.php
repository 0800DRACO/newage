<?php

namespace Database\Seeders;

// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Create admin user
        \DB::statement('INSERT IGNORE INTO users (id, name, email, password, created_at, updated_at) 
                        VALUES (1, ?, ?, ?, NOW(), NOW())',
            [
                env('ADMIN_NAME', 'Admin User'),
                env('ADMIN_EMAIL', 'admin@site.com'),
                bcrypt(env('ADMIN_PASSWORD', 'password')),
            ]
        );
    }
}
