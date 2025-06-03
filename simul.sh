#!/bin/bash

rm -rf /tmp/freechains

# pubpvt keys
PIONEIRO_PUBKEY=866A91FA15DCE1C717BA3C5EDF0B87559357C00717DE8789C5B6FE75F1EF6D51
PIONEIRO_PVTKEY=8F43A3E3AECE0E0DC00BBA08A6B9D36B12D45173BA9083C8023392DDA4F6D105866A91FA15DCE1C717BA3C5EDF0B87559357C00717DE8789C5B6FE75F1EF6D51

ATIVO_PUBKEY=E93E6640AD8EAC2B67B7393C7757938747CD8D73F2B576F9D337C868A4F3F68D
ATIVO_PVTKEY=4C54469E2F35E68C9BD3DB3D5BAAA85F321C851F7C460ED4D923B30CD1DF14C3E93E6640AD8EAC2B67B7393C7757938747CD8D73F2B576F9D337C868A4F3F68D

TROLL_PUBKEY=2ABAD11D891562B76BBD1C58CE05D3A34437546ACAD6ACC1BAD1CC6C6D79F352
TROLL_PVTKEY=FF054415514BFF0C017646BA2B91880B2436E2B08B261B468EEE442E8CF5C1632ABAD11D891562B76BBD1C58CE05D3A34437546ACAD6ACC1BAD1CC6C6D79F352

NOVATO_PUBKEY=77563B4BBFC0ADC2FDAC103DB30C5B7B6DE6989D86EC873E5AA85F39506D5B5D
NOVATO_PVTKEY=29F3A042D3C2389205F706E18B2EC6FA40A93A6EDE113068BBD27736E3FEB39677563B4BBFC0ADC2FDAC103DB30C5B7B6DE6989D86EC873E5AA85F39506D5B5D

NUM_USERS=4
FORUM_NAME="#FORUM"
ONE_DAY_MS=$((24 * 60 * 60 * 1000))
PIONEIRO_PORTA=5000
NOVATO_PORTA=5001
ATIVO_PORTA=5002
TROLL_PORTA=5003

OUTPUT_FILE_REP="reps_simulacao.txt"
OUTPUT_FILE_MSG="msgs_simulacao.txt"
DEPURACAO="depuracao.txt"

# Avanca o tempo de todos os peers em n dias
fastForward() {
    DAYS=$1 
    echo "Avançando $DAYS dia(s)..."
    echo
    SLICE=$((DAYS * ONE_DAY_MS))
    for id in {0..3};
    do
        PORT=$((5000 + id))
        CURRENT_TIME=$(./freechains-host now --port=$PORT)
        NEW_TIME=$((CURRENT_TIME + SLICE))
        ./freechains-host now "$NEW_TIME" --port=$PORT > /dev/null
        echo "Tempo do User $id: $NEW_TIME"
    done
    echo
    echo "Tempo atualizado para todos os peers!"
    echo

}

# Sincroniza os dados entre os peers
synchronizeUsers() {
    echo "Sincronizando..."
    for id in {1..3};
    do
        PORT=$((5000 + id))
        ./freechains --host=localhost:$PORT peer localhost:$PIONEIRO_PORTA send $FORUM_NAME
    done
    for id in {1..3};
    do
        PORT=$((5000 + id))
        ./freechains --host=localhost:$PIONEIRO_PORTA peer localhost:$PORT send $FORUM_NAME
    done
    echo "Sincronizacao concluida"
}

# Retorna a rep de um usuario
getUserReps() {
    echo $(./freechains --host=localhost:5000 chain $FORUM_NAME reps $1)
}

# Exibe a rep de todos os usuarios no forum no momento atual
showAllUserReps() {
    echo
    echo "====== REPUTACAO DO FORUM ======"
    dia=$(( $(./freechains-host now --port=$PIONEIRO_PORTA) / ONE_DAY_MS ))
    echo "DIA     : $dia"
    echo
    rep_pioneiro=$(getUserReps $PIONEIRO_PUBKEY)
    rep_ativo=$(getUserReps $ATIVO_PUBKEY)
    rep_troll=$(getUserReps $TROLL_PUBKEY)
    rep_novato=$(getUserReps $NOVATO_PUBKEY)
    echo "PIONEIRO: $rep_pioneiro"
    echo "ATIVO   : $rep_ativo"
    echo "TROLL   : $rep_troll"
    echo "NOVATO  : $rep_novato"
    echo
    rep_total=$((rep_pioneiro + rep_ativo + rep_troll + rep_novato))
    echo "REP TOTAL DO FORUM: $rep_total"
    echo "================================="
    echo
}
# Exibe mensagem, autor, rep atual e o dia
showPost(){
    ID=$1
    PORTA=$2  
    DIA=$(( $(./freechains-host now --port=$PIONEIRO_PORTA) / ONE_DAY_MS ))
    
    if [[ $PORTA -eq $PIONEIRO_PORTA ]]; then
    	REP=$(getUserReps "$PIONEIRO_PUBKEY")
    	echo "[PIONEIRO] REP: $REP DIA: $DIA: $(./freechains --port=$PORTA chain $FORUM_NAME get payload $ID)"
    fi
    if [[ $PORTA -eq $ATIVO_PORTA  ]]; then
    	REP=$(getUserReps "$ATIVO_PUBKEY")
    	echo "[ATIVO]   REP: $REP  DIA: $DIA: $(./freechains --port=$PORTA chain $FORUM_NAME get payload $ID)"
    fi
    if [[ $PORTA -eq $NOVATO_PORTA ]]; then
    	REP=$(getUserReps "$NOVATO_PUBKEY")
    	echo "[NOVATO] REP:  $REP  DIA:  $DIA: $(./freechains --port=$PORTA chain $FORUM_NAME get payload $ID)"
    fi

        if [[ $PORTA -eq $TROLL_PORTA ]]; then
        REP=$(getUserReps "$TROLL_PUBKEY")
    	echo "[TROLL]   REP: $REP  DIA: $DIA: $(./freechains --port=$PORTA chain $FORUM_NAME get payload $ID)"
    fi
       
}

# Escolhe aleatoriamente uma mensagem de um tipo (OK, NOT_OK, BAD) e publica
pickAndPost() {
    TIPO=$1
    PORTA=$2
    ID_PVTKEY=$3

    OK_POSTS=(
        "Dormir pra que? A XP não se farma sozinha"
        "Perdi a nocao do tempo, já amanheceu e eu nem vi."
        "Preciso de um headset novo, o meu tá com defeito."
        "Comprei a edicao de colecionador, valeu cada centavo."
        "Minha internet nao colabora"
        "Alguem gosta de Starcraft ?"
        "Meu ping tah alto pra caramba."
        "Soh paro quando passar de fase no Pokemon "
        "Que camp de XXXXX "
        "Vou jogar Pokemon !"
    )

    NOT_OK_POSTS=(
        "Dormir pra que? A XP não se farma sozinha!"
        "Desinstala, XXXXX !"
        "Alguem gosta de Starcraft ?"
        "Esse XXXXX nao sabe o que é objetivo!"
        "Minha internet nao colabora!"
        "Tá dando zika no meu jogo, XXXXX "
        "Meu ping tah alto pra caramba."
        "Soh paro quando passar de fase no Pokemon "
        "Que camp de XXXXX !!"
        "XXXXX XXXXX XXXXX."
    )

    BAD_POSTS=(
        "Que XXXXX de XXXXX!"
        "Desinstala essa XXXXX !"
        "FORUM DE XXXXX "
        "Esse XXXXX não sabe o que eh objetivo"
        "Sua vida eh um XXXXX de XXXXX."
        "Tah dando zika no meu jogo, XXXXX "
        "Voce fede a XXXXX "
        "Ok XXXXX "
        "Que lancamento de XXXXX "
        "XXXXX XXXXX XXXXX."
    )

    MESSAGE_RANDOM_NUMBER=$(shuf -i 0-9 -n 1)

    case "$TIPO" in
        OK)
            MESSAGE="${OK_POSTS[$MESSAGE_RANDOM_NUMBER]}"
            ;;
        NOT_OK)
            MESSAGE="${NOT_OK_POSTS[$MESSAGE_RANDOM_NUMBER]}"
            ;;
        BAD)
            MESSAGE="${BAD_POSTS[$MESSAGE_RANDOM_NUMBER]}"
            ;;
    esac

    ./freechains --host="localhost:$PORTA" chain "$FORUM_NAME" post inline "$MESSAGE" --sign="$ID_PVTKEY"
}
# Verifica se o hash de um post feito esta entre os heads
# Se o autor nao tinha rep suficiente ao postar, nao vai estar
isInHeads() {
	local hash="$1"
	local porta="$2"
	local heads=($(./freechains --host="localhost:$porta" chain "$FORUM_NAME" heads))
	
	for k in "${heads[@]}"; do
		if [[ "$k" == "$hash" ]]; then
			return 0 
		fi
	done

	return 1 
}

# Verifica se um termo esta presente na msg
findWord() {
    local texto="$1"
    local palavra="$2"

    if echo "$texto" | grep -wq "$palavra"; then
        echo 1
    else
        echo 0
    fi
}

# Usuarios vao reagir de acordo com o conteudo e rep dos autores
likeOrDislike() { # likeOrDislike user post_text keyword author_rep ID_msg
    local user=$1
    local post_text="$2"
    local keyword=$3
    local author_rep=$4
    local ID_MSG=$5

    contains_bad_content=$(findWord "$post_text" "$keyword")
    found_starcraft=$(findWord "$post_text" "Starcraft")
    found_pokemon=$(findWord "$post_text" "Pokemon")
    found_dormir=$(findWord "$post_text" "Dormir")

    if [ "$user" != "PIONEIRO" ]; then
        if [[ $contains_bad_content -eq 1 && $(getUserReps "$PIONEIRO_PUBKEY") -gt 5 && $author_rep -gt -1 ]]; then
            ./freechains chain $FORUM_NAME --port=$PIONEIRO_PORTA dislike $ID_MSG --sign=$PIONEIRO_PVTKEY > /dev/null
            echo "> PIONEIRO deu dislike no post do $user!"
        else
            if [[ $author_rep -gt -1 && $(getUserReps "$PIONEIRO_PUBKEY") -gt 5 && ( $found_starcraft -eq 1 || $found_pokemon -eq 1 || $found_dormir -eq 1 ) ]]; then
                ./freechains chain $FORUM_NAME --port=$PIONEIRO_PORTA like $ID_MSG --sign=$PIONEIRO_PVTKEY > /dev/null
                echo "> PIONEIRO deu like no post do $user!"
            fi
        fi
    fi
    if [ "$user" != "TROLL" ]; then
    	if [[ $(getUserReps "$TROLL_PUBKEY") -gt 5 && $author_rep -gt -1 ]]; then
            ./freechains chain $FORUM_NAME --port=$TROLL_PORTA dislike $ID_MSG --sign=$TROLL_PVTKEY > /dev/null
            echo "> TROLL deu dislike no post do $user!"
    	fi
    fi
    if [ "$user" != "ATIVO" ]; then
        if [[ $contains_bad_content -eq 1 && $(getUserReps "$ATIVO_PUBKEY") -gt 2 && $author_rep -gt -1 ]]; then
            ./freechains chain $FORUM_NAME --port=$ATIVO_PORTA dislike $ID_MSG --sign=$ATIVO_PVTKEY > /dev/null
            echo "> ATIVO deu dislike no post do $user!"
        else
            if [[ $author_rep -gt -1 && $found_pokemon -eq 1 && $(getUserReps "$ATIVO_PUBKEY") -gt 1 ]]; then
                ./freechains chain $FORUM_NAME --port=$ATIVO_PORTA like $ID_MSG --sign=$ATIVO_PVTKEY > /dev/null
                echo "> ATIVO deu like no post do $user!"
            fi
        fi
    fi
       if [ "$user" != "NOVATO" ]; then
        if [[ $contains_bad_content -eq 1 && $(getUserReps "$NOVATO_PUBKEY") -gt 3 && $author_rep -gt -1 ]]; then
            ./freechains chain $FORUM_NAME --port=$NOVATO_PORTA dislike $ID_MSG --sign=$NOVATO_PVTKEY > /dev/null
            echo "> NOVATO deu dislike no post do $user!"
        else
            if [[ $author_rep -gt -1 && $found_pokemon -eq 1 && $(getUserReps "$NOVATO_PUBKEY") -gt 3 ]]; then
                ./freechains chain $FORUM_NAME --port=$NOVATO_PORTA like $ID_MSG --sign=$NOVATO_PVTKEY > /dev/null
                echo "> NOVATO deu like no post do $user!"
            fi
        fi
    fi
	
}

#------------------------------------------------------------



echo "=== GENESIS: ==="

# Iniciar os Hosts em abas separadas do gnome-terminal
TERMINAL_CMD="gnome-terminal"
for (( id = 0; id < $NUM_USERS; id++ ))
do
    $TERMINAL_CMD --tab --title="Host $id" -- bash -c "./freechains-host --port=500$id start /tmp/freechains/host0$id; exec bash" &
    sleep 1
    ./freechains --host=localhost:500$id chains join $FORUM_NAME $PIONEIRO_PUBKEY
    ./freechains-host now 0 --port=500$id
    echo "Host do $id iniciado com sucesso."
done

# Post inicial de cada um sendo aprovado
ID_MSG=$(./freechains --host=localhost:$NOVATO_PORTA chain $FORUM_NAME post inline 'Ola, me aceite, por favor!' --sign=$NOVATO_PVTKEY)
./freechains --host=localhost:$NOVATO_PORTA peer localhost:$PIONEIRO_PORTA send $FORUM_NAME
showPost $ID_MSG $NOVATO_PORTA | tee -a "$OUTPUT_FILE_MSG"
./freechains chain ${FORUM_NAME} --port=$PIONEIRO_PORTA like $ID_MSG --sign=$PIONEIRO_PVTKEY

ID_MSG=$(./freechains --host=localhost:$ATIVO_PORTA chain $FORUM_NAME post inline 'Ola, me aceite, por favor!' --sign=$ATIVO_PVTKEY)
showPost $ID_MSG $ATIVO_PORTA | tee -a "$OUTPUT_FILE_MSG"
./freechains --host=localhost:$ATIVO_PORTA peer localhost:$PIONEIRO_PORTA send $FORUM_NAME
./freechains chain $FORUM_NAME --port=$PIONEIRO_PORTA like $ID_MSG --sign=$PIONEIRO_PVTKEY

ID_MSG=$(./freechains --host=localhost:$TROLL_PORTA chain $FORUM_NAME post inline 'Ola, me aceite, por favor!' --sign=$TROLL_PVTKEY)
./freechains --host=localhost:$TROLL_PORTA peer localhost:$PIONEIRO_PORTA send $FORUM_NAME
showPost $ID_MSG $TROLL_PORTA | tee -a "$OUTPUT_FILE_MSG"
./freechains chain $FORUM_NAME --port=$PIONEIRO_PORTA like $ID_MSG --sign=$PIONEIRO_PVTKEY

echo "> Todos os usuarios foram aceitos pelo PIONEIRO." >> $OUTPUT_FILE_MSG

showAllUserReps | tee -a "$OUTPUT_FILE_REP"

echo
echo "=== FORUM CRIADO COM SUCESSO ==="
echo
echo "=== SIMULACAO COMECA AGORA: ==="  
synchronizeUsers

# Primeiro mes
echo
echo "=== PRIMEIRO MES: ===" 
echo "TROLL se comporta como ATIVO." 
echo
for (( i = 1; i <= 30; i++ ))
do
    synchronizeUsers > /dev/null
    fastForward 1 > /dev/null
    showAllUserReps | tee -a "$OUTPUT_FILE_REP"
    
    # Pioneiro posta a cada 1 dia
    if (( i % 1 == 0 ));  then
        tipo="OK"
	HASH=$(pickAndPost "$tipo" "$PIONEIRO_PORTA" "$PIONEIRO_PVTKEY")
	synchronizeUsers > /dev/null
	if isInHeads "$HASH" "$PIONEIRO_PORTA"; then
		showPost "$HASH" "$PIONEIRO_PORTA" | tee -a "$OUTPUT_FILE_MSG"
		msg=$(./freechains --port=$PIONEIRO_PORTA chain $FORUM_NAME get payload $HASH) 
		likeOrDislike "PIONEIRO" "$msg" "XXXXX" $(getUserReps "$PIONEIRO_PUBKEY") "$HASH"  | tee -a "$OUTPUT_FILE_MSG"
	fi
    fi
    
    # Troll posta a cada 2 dias
    if (( i % 2 == 0 ));  then
        tipo="OK"
	HASH=$(pickAndPost "$tipo" "$TROLL_PORTA" "$TROLL_PVTKEY")
	synchronizeUsers > /dev/null
	if isInHeads "$HASH" "$TROLL_PORTA"; then
		showPost $HASH $TROLL_PORTA  | tee -a "$OUTPUT_FILE_MSG"
		msg=$(./freechains --port=$TROLL_PORTA chain $FORUM_NAME get payload $HASH) > /dev/null
		likeOrDislike "TROLL" "$msg" "XXXXX" $(getUserReps "$TROLL_PUBKEY") "$HASH"  | tee -a "$OUTPUT_FILE_MSG"
	fi
    fi
    
    # Ativo posta a cada 2 dias
   if (( i % 2 == 0 ));  then
       tipo="OK"
	HASH=$(pickAndPost "$tipo" "$ATIVO_PORTA" "$ATIVO_PVTKEY")
	synchronizeUsers > /dev/null
	if isInHeads "$HASH" "$ATIVO_PORTA"; then
		showPost $HASH $ATIVO_PORTA  | tee -a "$OUTPUT_FILE_MSG"
		msg=$(./freechains --port=$ATIVO_PORTA chain $FORUM_NAME get payload $HASH) > /dev/null
		likeOrDislike "ATIVO" "$msg" "XXXXX" $(getUserReps "$ATIVO_PUBKEY") "$HASH"  | tee -a "$OUTPUT_FILE_MSG"
	fi	
   fi
    # Novato posta a cada 6 dias
   if (( i % 6 == 0 ));  then
       tipo="OK"
	HASH=$(pickAndPost "$tipo" "$NOVATO_PORTA" "$NOVATO_PVTKEY")
	synchronizeUsers > /dev/null
	if isInHeads "$HASH" "$NOVATO_PORTA"; then
		showPost $HASH $NOVATO_PORTA  | tee -a "$OUTPUT_FILE_MSG"
		msg=$(./freechains --port=$NOVATO_PORTA chain $FORUM_NAME get payload $HASH)
		likeOrDislike "NOVATO" "$msg" "XXXXX" $(getUserReps "$NOVATO_PUBKEY") "$HASH"  | tee -a "$OUTPUT_FILE_MSG"
	fi
   fi        
done
echo
echo "=== SEGUNDO MES: ===" 
echo "TROLL posta mais mensagens improprias." 
echo
for (( i = 31; i <= 60; i++ ))
do
    synchronizeUsers > /dev/null
    fastForward 1 > /dev/null
    showAllUserReps | tee -a "$OUTPUT_FILE_REP"
    
    # Pioneiro posta a cada 1 dia
    if (( i % 1 == 0 ));  then
        tipo="OK"
	HASH=$(pickAndPost "$tipo" "$PIONEIRO_PORTA" "$PIONEIRO_PVTKEY")
	synchronizeUsers > /dev/null
	if isInHeads "$HASH" "$PIONEIRO_PORTA"; then
		showPost $HASH $PIONEIRO_PORTA | tee -a "$OUTPUT_FILE_MSG"
		msg=$(./freechains --port=$PIONEIRO_PORTA chain $FORUM_NAME get payload $HASH) > /dev/null
		likeOrDislike "PIONEIRO" "$msg" "XXXXX" $(getUserReps "$PIONEIRO_PUBKEY") "$HASH"  | tee -a "$OUTPUT_FILE_MSG"
	fi
    fi
    
    # Troll posta a cada 2 dias
    if (( i % 2 == 0 ));  then
        tipo="NOT_OK"
	HASH=$(pickAndPost "$tipo" "$TROLL_PORTA" "$TROLL_PVTKEY")
	synchronizeUsers > /dev/null
	if isInHeads "$HASH" "$TROLL_PORTA"; then
		showPost $HASH $TROLL_PORTA  | tee -a "$OUTPUT_FILE_MSG"
		msg=$(./freechains --port=$TROLL_PORTA chain $FORUM_NAME get payload $HASH) > /dev/null
		likeOrDislike "TROLL" "$msg" "XXXXX" $(getUserReps "$TROLL_PUBKEY") "$HASH"  | tee -a "$OUTPUT_FILE_MSG"
	fi
    fi
    
    # Ativo posta a cada 2 dias
   if (( i % 2 == 0 ));  then
       tipo="OK"
	HASH=$(pickAndPost "$tipo" "$ATIVO_PORTA" "$ATIVO_PVTKEY")
	synchronizeUsers > /dev/null
	if isInHeads "$HASH" "$ATIVO_PORTA"; then
		showPost $HASH $ATIVO_PORTA  | tee -a "$OUTPUT_FILE_MSG"
		msg=$(./freechains --port=$ATIVO_PORTA chain $FORUM_NAME get payload $HASH) > /dev/null
		likeOrDislike "ATIVO" "$msg" "XXXXX" $(getUserReps "$ATIVO_PUBKEY") "$HASH"  | tee -a "$OUTPUT_FILE_MSG"
	fi
   fi
    # Novato posta a cada 4 dias
   if (( i % 4 == 0 ));  then
       tipo="OK"
	HASH=$(pickAndPost "$tipo" "$NOVATO_PORTA" "$NOVATO_PVTKEY")
	synchronizeUsers > /dev/null
	if isInHeads "$HASH" "$NOVATO_PORTA"; then
		showPost $HASH $NOVATO_PORTA  | tee -a "$OUTPUT_FILE_MSG"
		msg=$(./freechains --port=$NOVATO_PORTA chain $FORUM_NAME get payload $HASH)
		likeOrDislike "NOVATO" "$msg" "XXXXX" $(getUserReps "$NOVATO_PUBKEY") "$HASH"  | tee -a "$OUTPUT_FILE_MSG"
	fi
   fi        
done

echo
echo "=== TERCEIRO MES: ===" 
echo "TROLL so posta mensagens improprias." 
echo
for (( i = 61; i <= 90; i++ ))
do
    synchronizeUsers > /dev/null
    fastForward 1 > /dev/null
    showAllUserReps | tee -a "$OUTPUT_FILE_REP"
    
    # Pioneiro posta a cada 1 dia
    if (( i % 1 == 0 ));  then
        tipo="OK"
	HASH=$(pickAndPost "$tipo" "$PIONEIRO_PORTA" "$PIONEIRO_PVTKEY")
	synchronizeUsers > /dev/null
	if isInHeads "$HASH" "$PIONEIRO_PORTA"; then
		showPost $HASH $PIONEIRO_PORTA | tee -a "$OUTPUT_FILE_MSG"
		msg=$(./freechains --port=$PIONEIRO_PORTA chain $FORUM_NAME get payload $HASH) > /dev/null
		likeOrDislike "PIONEIRO" "$msg" "XXXXX" $(getUserReps "$PIONEIRO_PUBKEY") "$HASH"  | tee -a "$OUTPUT_FILE_MSG"
	fi
    fi
    
    # Troll posta a cada 2 dias
    if (( i % 2 == 0 ));  then
        tipo="BAD"
	HASH=$(pickAndPost "$tipo" "$TROLL_PORTA" "$TROLL_PVTKEY")
	synchronizeUsers > /dev/null
	if isInHeads "$HASH" "$TROLL_PORTA"; then
		showPost $HASH $TROLL_PORTA  | tee -a "$OUTPUT_FILE_MSG"
		msg=$(./freechains --port=$TROLL_PORTA chain $FORUM_NAME get payload $HASH) > /dev/null
		likeOrDislike "TROLL" "$msg" "XXXXX" $(getUserReps "$TROLL_PUBKEY") "$HASH"  | tee -a "$OUTPUT_FILE_MSG"
	fi
    fi
    
    # Ativo posta a cada 2 dias
   if (( i % 2 == 0 ));  then
       tipo="OK"
	HASH=$(pickAndPost "$tipo" "$ATIVO_PORTA" "$ATIVO_PVTKEY")
	synchronizeUsers > /dev/null
	if isInHeads "$HASH" "$ATIVO_PORTA"; then
		showPost $HASH $ATIVO_PORTA  | tee -a "$OUTPUT_FILE_MSG"
		msg=$(./freechains --port=$ATIVO_PORTA chain $FORUM_NAME get payload $HASH) > /dev/null
		likeOrDislike "ATIVO" "$msg" "XXXXX" $(getUserReps "$ATIVO_PUBKEY") "$HASH"  | tee -a "$OUTPUT_FILE_MSG"
	fi
   fi
    # Novato posta a cada 2 dias
   if (( i % 2 == 0 ));  then
       tipo="OK"
	HASH=$(pickAndPost "$tipo" "$NOVATO_PORTA" "$NOVATO_PVTKEY")
	synchronizeUsers > /dev/null
	if isInHeads "$HASH" "$NOVATO_PORTA"; then
		showPost $HASH $NOVATO_PORTA  | tee -a "$OUTPUT_FILE_MSG"
		msg=$(./freechains --port=$NOVATO_PORTA chain $FORUM_NAME get payload $HASH)
		likeOrDislike "NOVATO" "$msg" "XXXXX" $(getUserReps "$NOVATO_PUBKEY") "$HASH"  | tee -a "$OUTPUT_FILE_MSG"
	fi
   fi        
done
echo
echo "=== SIMULACAO TERMINOU ==="
showAllUserReps | tee -a "$OUTPUT_FILE_REP"
echo
