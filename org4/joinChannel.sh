export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/crypto-config/peerOrganizations/org4.example.com/orderers/orderer0.org4.example.com/tls/tlscacerts/tls-localhost-10054-ca-org4-example-com.pem
export PEER0_ORG4_CA=${PWD}/crypto-config/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt
export PEER1_ORG4_CA=${PWD}/crypto-config/peerOrganizations/org4.example.com/peers/peer1.org4.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/../artifacts/channel/config/
export FABRIC_CFG_PATH=${PWD}/../artifacts/channel/config/

export CHANNEL_NAME=mychannel

setGlobalsForPeer0Org4() {
    export CORE_PEER_LOCALMSPID="Org4MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG4_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
    export CORE_PEER_ADDRESS=localhost:13051

}

setGlobalsForPeer1Org4() {
    export CORE_PEER_LOCALMSPID="Org4MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_ORG4_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
    export CORE_PEER_ADDRESS=localhost:14051

}

fetchChannelBlock() {
    rm -rf ./channel-artifacts/*
    setGlobalsForPeer0Org4

    # Replace localhost with your orderer's vm IP address
    peer channel fetch 0 ./channel-artifacts/$CHANNEL_NAME.block -o 51.38.54.24:10050 \
        --ordererTLSHostnameOverride orderer0.org4.example.com \
        -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
}

# fetchChannelBlock

joinChannel() {
    setGlobalsForPeer0Org4
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

    setGlobalsForPeer1Org4
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

}

# joinChannel

updateAnchorPeers() {
    setGlobalsForPeer0Org4

    # Replace localhost with your orderer's vm IP address
    peer channel update -o 51.38.54.24:10050 --ordererTLSHostnameOverride orderer0.org4.example.com \
        -c $CHANNEL_NAME -f ../artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

}

# updateAnchorPeers

# fetchChannelBlock
# joinChannel
# updateAnchorPeers
