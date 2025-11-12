@extends('layouts.app')

@section('content')
<div class="min-h-screen bg-gray-100 flex flex-col items-center py-10">
    <div class="w-full max-w-2xl bg-white shadow-lg rounded-2xl p-6">
        <h1 class="text-3xl font-bold text-center text-indigo-600 mb-6">📝 Lista de Tareas</h1>

        <!-- Formulario -->
        <form action="{{ route('tareas.store') }}" method="POST" class="flex mb-6 gap-2">
            @csrf
            <input 
                type="text" 
                name="titulo" 
                placeholder="Nueva tarea..." 
                class="flex-1 border border-gray-300 rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500" 
                required
            >
            <button type="submit" class="bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700">
                Agregar
            </button>
        </form>

        <!-- Tabla de tareas -->
        <div class="overflow-hidden rounded-lg border border-gray-200">
            <table class="w-full text-left">
                <thead class="bg-indigo-600 text-white">
                    <tr>
                        <th class="px-4 py-2">ID</th>
                        <th class="px-4 py-2">Título</th>
                        <th class="px-4 py-2 text-center">Acciones</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                    @foreach ($tareas as $tarea)
                        <tr class="hover:bg-gray-50">
                            <td class="px-4 py-2">{{ $tarea->id }}</td>
                            <td class="px-4 py-2">{{ $tarea->titulo }}</td>
                            <td class="px-4 py-2 text-center flex justify-center gap-2">
                                <a href="{{ route('tareas.edit', $tarea->id) }}" 
                                   class="bg-yellow-400 text-white px-3 py-1 rounded hover:bg-yellow-500">
                                   Editar
                                </a>
                                <form action="{{ route('tareas.destroy', $tarea->id) }}" method="POST" onsubmit="return confirm('¿Eliminar tarea?')">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600">
                                        Eliminar
                                    </button>
                                </form>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
</div>
@endsection
