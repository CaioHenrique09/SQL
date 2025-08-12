empresas-- Nome: Caio Henrique de Oliveira
-- Matrícula: 202525726

create table empresas (
    id_empresa int primary key auto_increment,
    nome_empresa varchar(30) not null,
    empresa_rua varchar(30) not null,
    empresa_cidade varchar(30) not null,
    empresa_bairro varchar(30) not null,
    empresa_estado varchar(30) not null,
    empresa_pais varchar(30) not null,
    empresa_tel varchar(30) not null,
    empresa_email varchar(30) not null,
    empresa_numrua varchar(30) not null,
    empresa_cpf_cnpj varchar(30) not null,
    empresa_cep varchar(30) not null,
    tipo_pessoa int not null,
    empresa_raz_soc varchar(30)
);

create table cadastro_banco (
    banco_id int primary key auto_increment,
    saldo_inicial float not null,
    banco_nome varchar(30) not null
);

create table contas_pagar (
    pagar_id int primary key auto_increment,
    empresa_id int,
    banco_id int,
    valor_pag float not null,
    dat_vencimento_pag date not null,
    dat_emissao_pag date not null,
    cod_barras int not null,
    constraint empresa_id_fk foreign key (empresa_id) references empresas(id_empresa),
    constraint banco_id_fk foreign key (banco_id) references cadastro_banco(banco_id)
);

create table contas_receber (
    receber_id int primary key auto_increment,
    empresa_id int,
    banco_id int,
    valor_rec float not null,
    data_venc_receber date not null,
    data_emissao_rec date not null,
    data_venc_emissao date not null,
    cod_barras_rec int not null,
    constraint fk_contas_rec_empresa foreign key (empresa_id) references empresas(id_empresa),
    constraint fk_contas_rec_banco foreign key (banco_id) references cadastro_banco(banco_id)
);
