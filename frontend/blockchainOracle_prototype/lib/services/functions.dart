// ignore_for_file: avoid_print
//packages
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:weatherapp/utils/constans.dart';

Future<DeployedContract> loadContract() async {
  String abi = await rootBundle.loadString('assets/abi.json');
  String contractAddress = contract_address;
  final contract = DeployedContract(
    ContractAbi.fromJson(abi, 'DataConsumerV3'),
    EthereumAddress.fromHex(contractAddress),
  );
  return contract;
}

Future<String> callFunction(String funcName, List<dynamic> args,
    Web3Client ethClient, String privateKey) async {
  EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
  DeployedContract contract = await loadContract();
  final ethFunction = contract.function(funcName);
  final result = await ethClient.sendTransaction(
    credentials,
    Transaction.callContract(
      contract: contract,
      function: ethFunction,
      parameters: args,
    ),
    chainId: null,
    fetchChainIdFromNetworkId: true,
  );
  return result;
}

Future<List> getLatestData(String feedAddress, Web3Client ethClient) async {
  List<dynamic> result = await request(
      'getLatestData', [EthereumAddress.fromHex(feedAddress)], ethClient);
  print('Transaction sent successfuly.');
  return result;
}

Future<List<dynamic>> request(
    String funcName, List<dynamic> args, Web3Client ethClient) async {
  final contract = await loadContract();
  final ethFunction = contract.function(funcName);
  final result =
      ethClient.call(contract: contract, function: ethFunction, params: args);
  return result;
}
