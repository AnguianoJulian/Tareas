<!DOCTYPE html>
<html>
<head>
    <title>Editar Tarea</title>
</head>
<body>
    <h1>Editar tarea</h1>

    <form action="{{ route('tareas.update', $tarea->id) }}" method="POST">
        @csrf
        @method('PUT')

        <label>Título:</label><br>
        <input type="text" name="titulo" value="{{ $tarea->titulo }}" required><br><br>

        <label>Descripción:</label><br>
        <textarea name="descripcion">{{ $tarea->descripcion }}</textarea><br><br>

        <label>
            <input type="checkbox" name="completada" value="1" {{ $tarea->completada ? 'checked' : '' }}>
            ¿Completada?
        </label><br><br>

        <button type="submit">Actualizar</button>
    </form>

    <a href="{{ route('tareas.index') }}">⬅️ Volver</a>
</body>
</html>
