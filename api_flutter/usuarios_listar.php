<?php
// api_flutter/usuarios_listar.php
require_once __DIR__ . '/config.php';

$sql = "SELECT raaluno, nomealuno, telauno, celaluno FROM alunos ORDER BY raaluno DESC";
$res = $conn->query($sql);

if (!$res) {
  respond(["erro" => "Erro na query: " . $conn->error], 500);
}

$dados = [];
while ($row = $res->fetch_assoc()) {
  $dados[] = $row;
}
respond($dados);
?>
