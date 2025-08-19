
-- =============================================
-- SCRIPT DE EXERCÍCIOS SQL (Contas a Pagar/Receber)
-- =============================================

-- Criação das tabelas (exemplo simplificado)
DROP TABLE IF EXISTS conta_a_pagar;
DROP TABLE IF EXISTS conta_a_receber;

CREATE TABLE conta_a_pagar (
    id_fatura INT PRIMARY KEY,
    nome_empresa VARCHAR(100),
    descricao VARCHAR(255),
    valor DECIMAL(10,2),
    vencimento DATE,
    pagamento DATE NULL
);

CREATE TABLE conta_a_receber (
    id_fatura INT PRIMARY KEY,
    nome_empresa VARCHAR(100),
    descricao VARCHAR(255),
    valor DECIMAL(10,2),
    vencimento DATE,
    pagamento DATE NULL
);

-- Inserts de exemplo
INSERT INTO conta_a_pagar VALUES 
(1, 'Empresa A', 'Energia elétrica', 1200.00, '2025-08-10', NULL),
(2, 'Empresa B', 'Internet', 300.00, '2025-08-12', '2025-08-15'),
(3, 'Empresa C', 'Água', 500.00, '2025-08-15', NULL);

INSERT INTO conta_a_receber VALUES
(10, 'Empresa A', 'Serviço prestado', 2000.00, '2025-08-18', NULL),
(11, 'Empresa D', 'Venda produto', 800.00, '2025-08-20', NULL),
(12, 'Empresa B', 'Serviço suporte', 600.00, '2025-08-15', '2025-08-16');

-- =============================================
-- 1) Relatório conta_a_pagar com dias em atraso
-- =============================================
SELECT 
    id_fatura,
    nome_empresa,
    descricao,
    valor,
    vencimento,
    COALESCE(pagamento, 'Não Pago') AS pagamento,
    CASE 
        WHEN pagamento IS NULL AND vencimento < CURRENT_DATE THEN DATEDIFF(CURRENT_DATE, vencimento)
        ELSE 0
    END AS dias_em_atraso
FROM conta_a_pagar;

-- =============================================
-- 2) Relatório conta_a_receber (não pagas)
-- =============================================
SELECT 
    nome_empresa,
    COUNT(*) AS qtd_faturas_nao_pagas,
    SUM(valor) AS total_nao_pago
FROM conta_a_receber
WHERE pagamento IS NULL
GROUP BY nome_empresa;

-- =============================================
-- 3) Empresas em pagar e não em receber
-- =============================================
SELECT 
    p.nome_empresa,
    SUM(p.valor) AS total_a_pagar
FROM conta_a_pagar p
WHERE p.nome_empresa NOT IN (SELECT r.nome_empresa FROM conta_a_receber r)
GROUP BY p.nome_empresa;

-- =============================================
-- 4) Relatório conta_a_receber com pagas e não pagas
-- =============================================
SELECT 
    nome_empresa,
    SUM(CASE WHEN pagamento IS NULL THEN 1 ELSE 0 END) AS qtd_nao_pagas,
    SUM(CASE WHEN pagamento IS NULL THEN valor ELSE 0 END) AS valor_nao_pago,
    SUM(CASE WHEN pagamento IS NOT NULL THEN 1 ELSE 0 END) AS qtd_pagas,
    SUM(CASE WHEN pagamento IS NOT NULL THEN valor ELSE 0 END) AS valor_pagas
FROM conta_a_receber
GROUP BY nome_empresa;

-- =============================================
-- 5) Fluxo de caixa (somente não pagas)
-- =============================================
SELECT 
    COALESCE(p.nome_empresa, r.nome_empresa) AS nome_empresa,
    COALESCE(p.id_fatura, r.id_fatura) AS id_fatura,
    COALESCE(p.descricao, r.descricao) AS descricao,
    p.valor AS debito,
    r.valor AS credito,
    COALESCE(p.vencimento, r.vencimento) AS vencimento
FROM conta_a_pagar p
FULL JOIN conta_a_receber r ON p.id_fatura = r.id_fatura
WHERE (p.pagamento IS NULL OR r.pagamento IS NULL)
ORDER BY vencimento;

-- =============================================
-- 6) Totalizar fluxo de caixa por dia
-- =============================================
SELECT 
    vencimento,
    STRFTIME('%w', vencimento) AS dia_semana,
    SUM(CASE WHEN debito IS NOT NULL THEN debito ELSE 0 END) AS total_a_pagar,
    SUM(CASE WHEN credito IS NOT NULL THEN credito ELSE 0 END) AS total_a_receber
FROM (
    SELECT nome_empresa, id_fatura, descricao, valor AS debito, NULL AS credito, vencimento
    FROM conta_a_pagar
    WHERE pagamento IS NULL
    UNION ALL
    SELECT nome_empresa, id_fatura, descricao, NULL AS debito, valor AS credito, vencimento
    FROM conta_a_receber
    WHERE pagamento IS NULL
) fluxo
GROUP BY vencimento;

-- =============================================
-- 7) Dias em que total a pagar > 1000
-- =============================================
SELECT 
    vencimento,
    STRFTIME('%w', vencimento) AS dia_semana,
    SUM(CASE WHEN debito IS NOT NULL THEN debito ELSE 0 END) AS total_a_pagar,
    SUM(CASE WHEN credito IS NOT NULL THEN credito ELSE 0 END) AS total_a_receber
FROM (
    SELECT nome_empresa, id_fatura, descricao, valor AS debito, NULL AS credito, vencimento
    FROM conta_a_pagar
    WHERE pagamento IS NULL
    UNION ALL
    SELECT nome_empresa, id_fatura, descricao, NULL AS debito, valor AS credito, vencimento
    FROM conta_a_receber
    WHERE pagamento IS NULL
) fluxo
GROUP BY vencimento
HAVING SUM(CASE WHEN debito IS NOT NULL THEN debito ELSE 0 END) > 1000;
