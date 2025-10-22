<?php
// api_flutter/usuarios_excluir.php (aceita ?id= ou JSON {id})
require_once __DIR__ . '/config.php';

$raaluno = 0;
if (isset($_GET['id'])) {
  $raaluno = intval($_GET['id']);
} else {
  $data = json_input();
  $raaluno = intval($data['id'] ?? 0);
}

if ($raaluno <= 0) respond(["erro" => "ID inválido"], 400);

$stmt = $conn->prepare("DELETE FROM alunos WHERE raaluno = ?");
$stmt->bind_param("i", $raaluno);

if ($stmt->execute()) {
  respond(["mensagem" => "Excluído com sucesso"]);
} else {
  respond(["erro" => "Falha ao excluir", "detalhe" => $conn->error], 500);
}
?>
