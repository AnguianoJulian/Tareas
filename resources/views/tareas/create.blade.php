<!DOCTYPE html>
<html>
<head>
    <title>Nueva Tarea</title>
</head>
<body>
    <h1>Crear nueva tarea</h1>

    <form action="{{ route('tareas.store') }}" method="POST">
        @csrf
        <label>Título:</label><br>
        <input type="text" name="titulo" required><br><br>

        <label>Descripción:</label><br>
        <textarea name="descripcion"></textarea><br><br>

        <button type="submit">Guardar</button>
    </form>

    <a href="{{ route('tareas.index') }}">⬅️ Volver</a>
</body>
</html>
