%% Base de conhecimento para diagnóstico de veículos autônomos

% Sintomas
sintoma(falha_ignicao, 'Falha de ignição ao dar a partida').
sintoma(luz_check_engine, 'Luz de “Check Engine” acesa').
sintoma(luz_bateria, 'Luz de bateria acesa no painel').
sintoma(barulho_motor, 'Barulho incomum no motor').

% Sensores
sensor(temperatura_motor, 'Sensor de temperatura do motor').
sensor(tensao_bateria, 'Sensor de tensão da bateria').
sensor(nivel_oleo, 'Sensor de nível de óleo').
sensor(rotacao_motor, 'Sensor de rotação do motor').

% Limites críticos dos sensores
limite_critico(temperatura_motor, 'Acima de 100°C', superaquecimento).
limite_critico(tensao_bateria, 'Abaixo de 12V', bateria_fraca).
limite_critico(nivel_oleo, 'Abaixo do mínimo', necessidade_troca_oleo).
limite_critico(rotacao_motor, 'Rotacao anormal', problema_injecao_ou_sensor_rotacao).

% Regras para inferência a partir dos sensores
% Utilizamos o corte (!) para evitar backtracking desnecessário após uma condição ser satisfeita.
inferencia_problema(temperatura_motor, Valor, superaquecimento) :-
    Valor > 100, !.

inferencia_problema(tensao_bateria, Valor, bateria_fraca) :-
    Valor < 12, !.

inferencia_problema(nivel_oleo, Valor, necessidade_troca_oleo) :-
    Valor =< 1, !.

inferencia_problema(rotacao_motor, Valor, problema_injecao_ou_sensor_rotacao) :-
    Valor < 600; Valor > 7000, !.

% Possíveis causas
causa(falha_ignicao, combustivel_insuficiente, alta).
causa(falha_ignicao, problema_bobina_ignicao, media).
causa(falha_ignicao, bateria_fraca, baixa).
causa(falha_ignicao, sensor_virabrequim_defeituoso, baixa).

causa(luz_check_engine, problema_sensores_motor, alta).
causa(luz_check_engine, falha_sistema_ignicao, media).
causa(luz_check_engine, emissao_excessiva_gases, media).
causa(luz_check_engine, problema_sensor_oxigenio, baixa).
causa(luz_check_engine, problema_sistema_injecao, media).

causa(luz_bateria, bateria_fraca, alta).
causa(luz_bateria, alternador_defeituoso, alta).
causa(luz_bateria, cabos_conexoes_frouxas, media).
causa(luz_bateria, correia_acessorios_rompida, baixa).

causa(barulho_motor, falta_lubrificacao, alta).
causa(barulho_motor, problema_valvulas_pistoes, media).
causa(barulho_motor, correia_dentada_desgastada, baixa).

% Regras para resolução de conflitos
% Utilizamos a prioridade para controlar quais causas devem ser consideradas primeiro em cenários de conflito.
prioridade(alta, media).
prioridade(media, baixa).

% Regra para resolver conflitos entre duas causas com base na prioridade
resolver_conflito(Causa1, Prob1, Causa2, Prob2, CausaPrioritaria) :-
    prioridade(Prob1, Prob2),
    !,  % Evita continuar avaliando após determinar a causa prioritária
    CausaPrioritaria = Causa1.
resolver_conflito(Causa1, Prob1, Causa2, Prob2, CausaPrioritaria) :-
    prioridade(Prob2, Prob1),
    !,  % Evita continuar avaliando após determinar a causa prioritária
    CausaPrioritaria = Causa2.
resolver_conflito(Causa1, _, Causa2, _, Causa1).  % Retorna a primeira causa caso nenhuma prioridade explícita seja encontrada

% Exemplo de regra combinada para múltiplos sintomas
combinar_sintomas(Sintoma1, Sintoma2, CausaCombinada) :-
    Sintoma1 = luz_check_engine,
    Sintoma2 = falha_ignicao,
    !,  % Garante que a combinação só ocorra para este cenário específico
    CausaCombinada = problema_sistema_injecao.

% Diagnóstico com múltiplos sintomas
% Esta regra combina sintomas e escolhe a causa mais provável com base nas probabilidades

diagnostico_combinado(Sintoma1, Sintoma2, CausaPrioritaria, Acao) :-
    combinar_sintomas(Sintoma1, Sintoma2, CausaCombinada),
    CausaPrioritaria = CausaCombinada,
    acao(CausaCombinada, Acao).

% Ações corretivas associadas a falhas
acao(combustivel_insuficiente, 'Reabasteça o veículo com combustível adequado').
acao(problema_bobina_ignicao, 'Verifique e substitua a bobina de ignição, se necessário').
acao(problema_bobina_ignicao, 'Limpar ou trocar velas de ignição').
acao(bateria_fraca, 'Carregue ou substitua a bateria').
acao(bateria_fraca, 'Verifique e recarregue a bateria').
acao(sensor_virabrequim_defeituoso, 'Substitua o sensor de posição do virabrequim').

acao(problema_sensores_motor, 'Inspecione e substitua os sensores do motor').
acao(falha_sistema_ignicao, 'Verifique o sistema de ignição e realize reparos').
acao(emissao_excessiva_gases, 'Realize manutenção no sistema de emissões').
acao(problema_sensor_oxigenio, 'Substitua o sensor de oxigênio').
acao(problema_sistema_injecao, 'Verifique e repare o sistema de injeção').

acao(alternador_defeituoso, 'Substitua o alternador ou conserte-o').
acao(cabos_conexoes_frouxas, 'Aperte ou substitua os cabos e conexões da bateria').
acao(correia_acessorios_rompida, 'Substitua a correia de acessórios').
acao(correia_acessorios_rompida, 'Substituir a correia do alternador').

acao(falta_lubrificacao, 'Verifique o nível de óleo e complete, se necessário').
acao(falta_lubrificacao, 'Checar o nível de óleo').
acao(falta_lubrificacao, 'Troque o óleo se necessário').
acao(problema_valvulas_pistoes, 'Realize manutenção nas válvulas e pistões').
acao(correia_dentada_desgastada, 'Substitua a correia dentada').

% Regras para diagnóstico com probabilidade
diagnostico(Sintoma, Causa, Acao, Probabilidade) :-
    sintoma(Sintoma, _),
    causa(Sintoma, Causa, Probabilidade),
    acao(Causa, Acao).

% Regras para justificativa do diagnóstico
% Esta regra explica como o sistema chegou à conclusão de uma falha
justificativa_diagnostico(Sintoma, Causa, Justificativa) :-
    sintoma(Sintoma, DescricaoSintoma),
    causa(Sintoma, Causa, Probabilidade),
    format(atom(Justificativa), 'O sintoma identificado foi "~w". A causa mais provável (~w) foi determinada com base na prioridade atribuída a este problema.', [DescricaoSintoma, Probabilidade]).

% Regras para explicação do descarte de causas
justificativa_descartada(Sintoma, CausaDescartada, CausaSelecionada, Justificativa) :-
    sintoma(Sintoma, DescricaoSintoma),
    causa(Sintoma, CausaDescartada, Prob1),
    causa(Sintoma, CausaSelecionada, Prob2),
    prioridade(Prob2, Prob1),
    format(atom(Justificativa), 'Para o sintoma "~w", a causa "~w" foi descartada porque a causa "~w" tem maior prioridade (~w > ~w).', [DescricaoSintoma, CausaDescartada, CausaSelecionada, Prob2, Prob1]).

% Exemplo para consulta
% Para obter o diagnóstico:
% ?- diagnostico(falha_ignicao, Causa, Acao, Probabilidade).
% ?- diagnostico(luz_check_engine, Causa, Acao, Probabilidade).
% ?- diagnostico(Sintoma, Causa, Acao, Probabilidade).
% ?- causa(Sintoma, bateria_fraca,  Probabilidade).
% ?- sensor(Sensor, Descricao).
% ?- sensor(temperatura_motor, Descricao).
% ?- acao(sensor_virabrequim_defeituoso, Acao).
% ?- causa(luz_check_engine, Causa, Probabilidade).
% ?- limite_critico(temperatura_motor, Limite, Diagnostico).
% ?- limite_critico(Sensor, Limite, Diagnostico).
% ?- limite_critico(Sensor, Limite, superaquecimento).
% ?- diagnostico(luz_check_engine, Causa, Acao, Probabilidade), limite_critico(temperatura_motor, Limite, superaquecimento).
% ?- inferencia_problema(temperatura_motor, 105, Problema).
% ?- resolver_conflito(problema_sensor_oxigenio, baixa, problema_bobina_ignicao, media, CausaPrioritaria).
% ?- diagnostico(falha_ignicao, Causa, Acao, Probabilidade).
% ?- diagnostico_combinado(luz_check_engine, falha_ignicao, CausaPrioritaria, Acao).
% ?- justificativa_descartada(falha_ignicao, CausaDescartada, CausaSelecionada, Justificativa).

