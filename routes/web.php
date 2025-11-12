<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\TareaController;

Route::get('/', function () {
    return redirect()->route('tareas.index');
});

Route::resource('tareas', TareaController::class);
