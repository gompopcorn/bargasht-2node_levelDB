export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/crypto-config/peerOrganizations/org5.example.com/orderers/orderer0.org5.example.com/tls/tlscacerts/tls-localhost-11054-ca-org5-example-com.pem
export PEER0_ORG5_CA=${PWD}/crypto-config/peerOrganizations/org5.example.com/peers/peer0.org5.example.com/tls/ca.crt
export PEER1_ORG5_CA=${PWD}/crypto-config/peerOrganizations/org5.example.com/peers/peer1.org5.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/../artifacts/channel/config/
export FABRIC_CFG_PATH=${PWD}/../artifacts/channel/config/

export CHANNEL_NAME=mychannel

setGlobalsForPeer0Org5() {
    export CORE_PEER_LOCALMSPID="Org5MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG5_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org5.example.com/users/Admin@org5.example.com/msp
    export CORE_PEER_ADDRESS=localhost:15051

}

setGlobalsForPeer1Org5() {
    export CORE_PEER_LOCALMSPID="Org5MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_ORG5_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org5.example.com/users/Admin@org5.example.com/msp
    export CORE_PEER_ADDRESS=localhost:16051

}

fetchChannelBlock() {
    rm -rf ./channel-artifacts/*
    setGlobalsForPeer0Org5

    # Replace localhost with your orderer's vm IP address
    peer channel fetch 0 ./channel-artifacts/$CHANNEL_NAME.block -o 142.132.133.167:11050 \
        --ordererTLSHostnameOverride orderer0.org5.example.com \
        -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
}

# fetchChannelBlock

joinChannel() {
    setGlobalsForPeer0Org5
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

    setGlobalsForPeer1Org5
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

}

# joinChannel

updateAnchorPeers() {
    setGlobalsForPeer0Org5

    # Replace localhost with your orderer's vm IP address
    peer channel update -o 142.132.133.167:11050 --ordererTLSHostnameOverride orderer0.org5.example.com \
        -c $CHANNEL_NAME -f ../artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

}

# updateAnchorPeers

# fetchChannelBlock
# joinChannel
# updateAnchorPeers