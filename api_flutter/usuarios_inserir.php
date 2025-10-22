<?php
// api_flutter/usuarios_inserir.php
require_once __DIR__ . '/config.php';

$data = json_input();
$nomealuno = trim($data['nomealuno'] ?? '');
$telaluno = trim($data['telaluno'] ?? '');
$celaluno = trim($data['celaluno'] ?? '');

if ($nomealuno === '') respond(["erro" => "Nome é obrigatório"], 400);

$stmt = $conn->prepare("INSERT INTO alunos (nomealuno, telaluno, celaluno) VALUES (?, ?, ?)");
$stmt->bind_param("sss", $nomealuno, $telaluno, $celaluno);

if ($stmt->execute()) {
  $raaluno = $stmt->insert_id;
  respond(["mensagem" => "Inserido com sucesso", "id" => $raaluno], 201);
} else {
  respond(["erro" => "Falha ao inserir", "detalhe" => $conn->error], 500);
}
?>
