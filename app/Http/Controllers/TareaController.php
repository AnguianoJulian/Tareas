<?php

namespace App\Http\Controllers;

use App\Models\Tarea;
use Illuminate\Http\Request;

class TareaController extends Controller
{
    // Mostrar todas las tareas
    public function index()
    {
        $tareas = Tarea::all();
        return view('tareas.index', compact('tareas'));
    }

    // Mostrar formulario de creación
    public function create()
    {
        return view('tareas.create');
    }

    // Guardar nueva tarea
    public function store(Request $request)
    {
        $request->validate([
            'titulo' => 'required|string|max:255',
            'descripcion' => 'nullable|string',
        ]);

        Tarea::create([
            'titulo' => $request->titulo,
            'descripcion' => $request->descripcion,
            'completada' => false,
        ]);

        return redirect()->route('tareas.index')->with('success', 'Tarea creada correctamente.');
    }

    // Mostrar formulario de edición
    public function edit(Tarea $tarea)
    {
        return view('tareas.edit', compact('tarea'));
    }

    // Actualizar tarea existente
    public function update(Request $request, Tarea $tarea)
    {
        $request->validate([
            'titulo' => 'required|string|max:255',
            'descripcion' => 'nullable|string',
            'completada' => 'boolean',
        ]);

        $tarea->update($request->all());

        return redirect()->route('tareas.index')->with('success', 'Tarea actualizada correctamente.');
    }

    // Eliminar tarea
    public function destroy(Tarea $tarea)
    {
        $tarea->delete();

        return redirect()->route('tareas.index')->with('success', 'Tarea eliminada correctamente.');
    }
}
