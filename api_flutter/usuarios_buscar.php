<?php
// api_flutter/usuarios_buscar.php
require_once __DIR__ . '/config.php';

$raaluno = 0;
if (isset($_GET['id'])) {
  $raaluno = intval($_GET['id']);
} else {
  $data = json_input();
  $raaluno = intval($data['id'] ?? 0);
}

if ($raaluno <= 0) respond(["erro" => "ID inválido"], 400);

$stmt = $conn->prepare("SELECT raaluno, nomealuno, telaluno, celaluno FROM alunos WHERE raaluno = ?");
$stmt->bind_param("i", $raaluno);
$stmt->execute();
$res = $stmt->get_result();

if ($res->num_rows === 0) {
  respond(["erro" => "Usuário não encontrado"], 404);
}

$usuario = $res->fetch_assoc();
respond($usuario);
?>
