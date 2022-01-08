export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/crypto-config/peerOrganizations/org1.example.com/orderers/orderer0.org1.example.com/tls/tlscacerts/tls-localhost-7054-ca-org1-example-com.pem
export PEER1_ORG1_CA=${PWD}/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt
export PEER1_ORG2_CA=${PWD}/../org2/crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt
export PEER1_ORG3_CA=${PWD}/../org3/crypto-config/peerOrganizations/org3.example.com/peers/peer1.org3.example.com/tls/ca.crt
export PEER1_ORG4_CA=${PWD}/../org4/crypto-config/peerOrganizations/org4.example.com/peers/peer1.org4.example.com/tls/ca.crt
export PEER1_ORG5_CA=${PWD}/../org5/crypto-config/peerOrganizations/org5.example.com/peers/peer1.org5.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/../artifacts/channel/config/


export CHANNEL_NAME=mychannel

setGlobalsForPeer1Org1() {
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:8051
}

presetup() {
    echo Vendoring Go dependencies ...
    pushd ../artifacts/src/github.com/fabcar/go
    GO111MODULE=on go mod vendor
    popd
    echo Finished vendoring Go dependencies
}
# presetup

CHANNEL_NAME="mychannel"
CC_RUNTIME_LANGUAGE="golang"
VERSION="1"
CC_SRC_PATH="../artifacts/src/github.com/fabcar/go"
CC_NAME="fabcar"

packageChaincode() {
    rm -rf ${CC_NAME}.tar.gz
    setGlobalsForPeer1Org1
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged on peer1.org1 ===================== "
}
# packageChaincode

installChaincode() {
    setGlobalsForPeer1Org1
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer1.org1 ===================== "

}

# installChaincode

queryInstalled() {
    setGlobalsForPeer1Org1
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer1.org1 on channel ===================== "
}

# queryInstalled

approveForMyOrg1() {
    setGlobalsForPeer1Org1
    # set -x
    # Replace localhost with your orderer's vm IP address
    peer lifecycle chaincode approveformyorg -o 142.132.146.95:7050 \
        --ordererTLSHostnameOverride orderer0.org1.example.com --tls \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}
    # set +x

    echo "===================== chaincode approved from org1 ===================== "

}

# queryInstalled
# approveForMyOrg1

checkCommitReadyness() {
    setGlobalsForPeer1Org1
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org1 ===================== "
}

# checkCommitReadyness

# this will be run in the cli container
commitChaincodeDefination() {
    setGlobalsForPeer1Org1
    peer lifecycle chaincode commit -o 142.132.146.95:7050 --ordererTLSHostnameOverride orderer0.org1.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses localhost:8051 --tlsRootCertFiles $PEER1_ORG1_CA \
        --peerAddresses localhost:10051 --tlsRootCertFiles $PEER1_ORG2_CA \
        --peerAddresses localhost:12051 --tlsRootCertFiles $PEER1_ORG3_CA \
        --peerAddresses localhost:14051 --tlsRootCertFiles $PEER1_ORG4_CA \
        --peerAddresses localhost:16051 --tlsRootCertFiles $PEER1_ORG5_CA \
        --version ${VERSION} --sequence ${VERSION} --init-required
}

# commitChaincodeDefination

queryCommitted() {
    setGlobalsForPeer1Org1
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}

# queryCommitted

# this will be run in the cli container
chaincodeInvokeInit() {
    setGlobalsForPeer1Org1
    peer chaincode invoke -o 142.132.146.95:7050 \
        --ordererTLSHostnameOverride orderer0.org1.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:10051 --tlsRootCertFiles $PEER1_ORG2_CA \
        --peerAddresses localhost:12051 --tlsRootCertFiles $PEER1_ORG3_CA \
        --peerAddresses localhost:14051 --tlsRootCertFiles $PEER1_ORG4_CA \
        --peerAddresses localhost:16051 --tlsRootCertFiles $PEER1_ORG5_CA \
        --isInit -c '{"Args":[]}'

}

# chaincodeInvokeInit

# this will be run in the cli container
chaincodeInvoke() {
    setGlobalsForPeer1Org1

    ## Create Car
    peer chaincode invoke -o 142.132.146.95:7050 \
        --ordererTLSHostnameOverride orderer0.org1.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:8051 --tlsRootCertFiles $PEER1_ORG1_CA \
        --peerAddresses localhost:10051 --tlsRootCertFiles $PEER1_ORG2_CA   \
        --peerAddresses localhost:12051 --tlsRootCertFiles $PEER1_ORG3_CA \
        --peerAddresses localhost:14051 --tlsRootCertFiles $PEER1_ORG4_CA \
        --peerAddresses localhost:16051 --tlsRootCertFiles $PEER1_ORG5_CA \
        -c '{"function": "createCar","Args":["Car-ABCDEEE", "Audi", "R8", "Red", "Sandip"]}'

}

# chaincodeInvoke

# this will be run in the cli container
chaincodeQuery() {
    setGlobalsForPeer1Org1

    # Query Car by Id
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "queryCar","Args":["CAR0"]}'
 
}

# chaincodeQuery

# Run this function if you add any new dependency in chaincode
# presetup
# installChaincode
# queryInstalled
# approveForMyOrg1
# checkCommitReadyness