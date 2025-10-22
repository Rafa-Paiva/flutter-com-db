<?php
// api_flutter/usuarios_atualizar.php
require_once __DIR__ . '/config.php';

$data = json_input();
$raaluno = intval($data['raaluno'] ?? 0);
$nomealuno = trim($data['nomealuno'] ?? '');
$telaluno = trim($data['telaluno'] ?? '');
$celaluno = trim($data['celaluno'] ?? '');

if ($raaluno <= 0) respond(["erro" => "ID inválido"], 400);
if ($nomealuno === '') respond(["erro" => "Nome é obrigatório"], 400);

$stmt = $conn->prepare("UPDATE alunos SET nomealuno = ?, telaluno = ?, celaluno = ? WHERE raaluno = ?");
$stmt->bind_param("sssi", $nomealuno, $telaluno, $celaluno, $raaluno);

if ($stmt->execute()) {
  respond(["mensagem" => "Atualizado com sucesso"]);
} else {
  respond(["erro" => "Falha ao atualizar", "detalhe" => $conn->error], 500);
}
?>
