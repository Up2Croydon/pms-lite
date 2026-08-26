<?php

namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;

abstract class TestCase extends BaseTestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        
        // 确保在 CI 环境中运行迁移
        if (env('CI') || env('APP_ENV') === 'testing') {
            $this->artisan('migrate:fresh');
        }
    }
}
