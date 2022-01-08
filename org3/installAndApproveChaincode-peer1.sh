export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/crypto-config/peerOrganizations/org3.example.com/orderers/orderer0.org3.example.com/tls/tlscacerts/tls-localhost-9054-ca-org3-example-com.pem
export PEER1_ORG3_CA=${PWD}/crypto-config/peerOrganizations/org3.example.com/peers/peer1.org3.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/../artifacts/channel/config/
export PATH=${PWD}/../../bin:$PATH


export CHANNEL_NAME=mychannel

setGlobalsForPeer1Org3() {
    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_ORG3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
    export CORE_PEER_ADDRESS=localhost:12051

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
    setGlobalsForPeer1Org3
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged on peer1.org3 ===================== "
}
# packageChaincode

installChaincode() {
    setGlobalsForPeer1Org3
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer1.org3 ===================== "

}

# installChaincode

queryInstalled() {
    setGlobalsForPeer1Org3
    peer lifecycle chaincode queryinstalled >&log.txt

    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer1.org3 on channel ===================== "
}

# queryInstalled

approveForMyOrg3() {
    setGlobalsForPeer1Org3

    peer lifecycle chaincode approveformyorg -o 144.76.102.218:9050 \
        --ordererTLSHostnameOverride orderer0.org3.example.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}

    echo "===================== chaincode approved from org3 ===================== "
}
# queryInstalled
# approveForMyOrg3

checkCommitReadyness() {

    setGlobalsForPeer1Org3
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:12051 --tlsRootCertFiles $PEER1_ORG3_CA \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org3 ===================== "
}

# checkCommitReadyness



# presetup
# packageChaincode
# installChaincode
# queryInstalled
# approveForMyOrg3
# checkCommitReadyness