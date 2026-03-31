-- ============================================================================
-- ETAPA 3.7: DESEMPENHO E PERFORMANCE TUNING
-- Escolha de 2 consultas lentas, aplicação de melhorias e medição de ganhos
-- Técnicas: Índices, reescrita de queries, EXPLAIN ANALYZE
-- ============================================================================

-- ============================================================================
-- CONSULTA LENTA 1: RELATÓRIO DE FATURAMENTO POR FUNCIONÁRIO COM JOINS
-- Problema: Múltiplos JOINs + Agregações sem índices otimizados
-- Cenário: Dashboard executivo consultado frequentemente
-- ============================================================================

-- ANTES DA OTIMIZAÇÃO
-- Desabilitar índices temporariamente para simular consulta lenta
SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;



-- Consulta original (SEM otimização)
EXPLAIN ANALYZE
SELECT
    f.nome_completo AS vendedor,
    d.nome_destino,
    d.pais,
    COUNT(r.id_reserva) AS total_vendas,
    SUM(r.numero_passageiros) AS total_passageiros,
    SUM(r.valor_total) AS receita_total,
    AVG(r.desconto_percentual) AS desconto_medio
FROM tb_funcionarios f
INNER JOIN tb_reservas r ON f.id_funcionario = r.id_funcionario
INNER JOIN tb_pacotes_turisticos p ON r.id_pacote = p.id_pacote
INNER JOIN tb_destinos d ON p.id_destino = d.id_destino
WHERE r.status_reserva IN ('CONFIRMADA', 'FINALIZADA')
AND r.data_reserva >= '2024-01-01'
GROUP BY f.id_funcionario, f.nome_completo, d.id_destino, d.nome_destino, d.pais
ORDER BY receita_total DESC;



/*
RESULTADO ESPERADO (ANTES):
- Seq Scan em múltiplas tabelas
- Hash Joins pesados
*/

-- Reabilitar índices
SET enable_indexscan = ON;
SET enable_bitmapscan = ON;

-- DEPOIS DA OTIMIZAÇÃO 1: Criar índices estratégicos
-- Índice para acelerar filtro por data e status
CREATE INDEX IF NOT EXISTS idx_reservas_data_status_otim
ON tb_reservas (data_reserva, status_reserva)
WHERE status_reserva IN ('CONFIRMADA', 'FINALIZADA');

-- Índice para acelerar JOINs
CREATE INDEX IF NOT EXISTS idx_reservas_funcionario_pacote
ON tb_reservas (id_funcionario, id_pacote);

ANALYZE tb_reservas;
ANALYZE tb_funcionarios;
ANALYZE tb_pacotes_turisticos;



-- Consulta otimizada (COM índices)
EXPLAIN ANALYZE
SELECT
    f.nome_completo AS vendedor,
    d.nome_destino,
    d.pais,
    COUNT(r.id_reserva) AS total_vendas,
    SUM(r.numero_passageiros) AS total_passageiros,
    SUM(r.valor_total) AS receita_total,
    AVG(r.desconto_percentual) AS desconto_medio
FROM tb_funcionarios f
INNER JOIN tb_reservas r ON f.id_funcionario = r.id_funcionario
INNER JOIN tb_pacotes_turisticos p ON r.id_pacote = p.id_pacote
INNER JOIN tb_destinos d ON p.id_destino = d.id_destino
WHERE r.status_reserva IN ('CONFIRMADA', 'FINALIZADA')
AND r.data_reserva >= '2024-01-01'
GROUP BY f.id_funcionario, f.nome_completo, d.id_destino, d.nome_destino, d.pais
ORDER BY receita_total DESC;



/*
RESULTADO ESPERADO (DEPOIS):
- Index Scans ao invés de Seq Scans
- Merge Joins mais eficientes
*/

-- ============================================================================
-- CONSULTA LENTA 2: BUSCA DE PACOTES COM DISPONIBILIDADE DINÂMICA
-- Problema: Subconsultas correlacionadas executadas para cada linha
-- Cenário: Página de busca de pacotes no site
-- ============================================================================

-- ANTES DA OTIMIZAÇÃO
SET enable_indexscan = OFF;



-- Consulta original (subconsultas correlacionadas)
EXPLAIN ANALYZE
SELECT
    p.id_pacote,
    p.nome_pacote,
    d.nome_destino,
    p.preco_total,
    p.vagas_disponiveis,
    (SELECT COALESCE(SUM(r.numero_passageiros), 0)
     FROM tb_reservas r
     WHERE r.id_pacote = p.id_pacote
     AND r.status_reserva IN ('CONFIRMADA', 'PENDENTE')) AS vagas_vendidas,
    (p.vagas_disponiveis - (
        SELECT COALESCE(SUM(r.numero_passageiros), 0)
        FROM tb_reservas r
        WHERE r.id_pacote = p.id_pacote
        AND r.status_reserva IN ('CONFIRMADA', 'PENDENTE')
    )) AS vagas_restantes
FROM tb_pacotes_turisticos p
INNER JOIN tb_destinos d ON p.id_destino = d.id_destino
WHERE p.status = 'DISPONIVEL'
AND p.data_inicio >= CURRENT_DATE
ORDER BY p.data_inicio ASC;



/*
RESULTADO ESPERADO (ANTES):
- Subconsultas executadas N vezes (uma por pacote)
- Seq Scan em tb_reservas para cada subconsulta
*/

SET enable_indexscan = ON;

-- DEPOIS DA OTIMIZAÇÃO 2A: Reescrever query com LEFT JOIN


EXPLAIN ANALYZE
SELECT
    p.id_pacote,
    p.nome_pacote,
    d.nome_destino,
    p.preco_total,
    p.vagas_disponiveis,
    COALESCE(SUM(r.numero_passageiros), 0) AS vagas_vendidas,
    p.vagas_disponiveis - COALESCE(SUM(r.numero_passageiros), 0) AS vagas_restantes
FROM tb_pacotes_turisticos p
INNER JOIN tb_destinos d ON p.id_destino = d.id_destino
LEFT JOIN tb_reservas r ON p.id_pacote = r.id_pacote
    AND r.status_reserva IN ('CONFIRMADA', 'PENDENTE')
WHERE p.status = 'DISPONIVEL'
AND p.data_inicio >= CURRENT_DATE
GROUP BY p.id_pacote, p.nome_pacote, d.nome_destino, p.preco_total, p.vagas_disponiveis
ORDER BY p.data_inicio ASC;



/*
RESULTADO ESPERADO (DEPOIS):
- LEFT JOIN executado apenas uma vez
- Hash Join eficiente
*/

-- OTIMIZAÇÃO 2B: Usar a VIEW pré-calculada (melhor opção)


EXPLAIN ANALYZE
SELECT
    id_pacote,
    nome_pacote,
    nome_destino,
    preco_total
FROM vw_pacotes_completos
ORDER BY data_inicio ASC;
