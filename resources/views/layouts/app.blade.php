<!-- resources/views/layouts/app.blade.php -->
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'TareasApp')</title>
    @vite('resources/css/app.css')
</head>
<body>
    <div class="container">
        @yield('content')
    </div>
    @vite('resources/js/app.js')
</body>
</html>
