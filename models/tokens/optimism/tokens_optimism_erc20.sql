{{ config( alias='erc20', tags=['static'],
    post_hook='{{ expose_spells(\'["optimism"]\',
                                    "sector",
                                    "tokens",
                                    \'["msilb7"]\') }}')}}

-- token_type: What best describes this token? Is it a vault or LP token, or a lowest-level underlying token?
  -- underlying: This is the rawest form of the token (i.e. USDC, DAI, WETH, OP, UNI, GTC) - Counted in On-Chain Value
  -- receipt: This is a vault/LP receipt token (i.e. HOP-LP-USDC, aUSDC, LP Tokens) - NOT Counted in On-Chain Value (double count)
  -- na: This is a placeholder token that does not have a price

WITH raw_token_list AS (
 SELECT 
 LOWER(contract_address) AS contract_address
      , symbol
      , decimals
      , token_type
    FROM (VALUES 
     ('0x4200000000000000000000000000000000000006', 'WETH', 18, 'underlying')
    ,('0xda10009cbd5d07dd0cecc66161fc93d7c9000da1', 'DAI', 18, 'underlying')
    ,('0x68f180fcce6836688e9084f035309e29bf0a2095', 'WBTC', 8, 'underlying')
    ,('0x94b008aa00579c1307b0ef2c499ad98a8ce58e58', 'USDT', 6, 'underlying')
    ,('0x8700daec35af8ff88c16bdf0418774cb3d7599b4', 'SNX', 18, 'underlying')
    ,('0x350a791bfc2c21f9ed5d10980dad2e2638ffa7f6', 'LINK', 18, 'underlying')
    ,('0xb548f63d4405466b36c0c0ac3318a22fdcec711a', 'RGT', 18, 'underlying')
    ,('0xab7badef82e9fe11f6f33f87bc9bc2aa27f2fcb5', 'MKR', 18, 'underlying')
    ,('0x6fd9d7ad17242c41f7131d257212c54a0e816691', 'UNI', 18, 'underlying')
    ,('0x7fb688ccf682d58f86d7e38e03f9d22e7705448b', 'RAI', 18, 'underlying')
    ,('0x7f5c764cbc14f9669b88837ca1490cca17c31607', 'USDC', 6, 'underlying')
    ,('0x8c6f28f2f1a3c87f0f938b96d27520d9751ec8d9', 'sUSD', 18, 'underlying')
    ,('0xe405de8f52ba7559f9df3c368500b6e6ae6cee49', 'sETH', 18, 'underlying')
    ,('0xc5db22719a06418028a40a9b5e9a7c02959d0d08', 'sLINK', 18, 'underlying')
    ,('0x298b9b95708152ff6968aafd889c6586e9169f1d', 'sBTC', 18, 'underlying')
    ,('0x25d8039bb044dc227f741a9e381ca4ceae2e6ae8', 'hUSDC', 6, 'underlying') --hop transfer token
    ,('0x2057c8ecb70afd7bee667d76b4cd373a325b1a20', 'hUSDT', 6, 'underlying')
    ,('0x56900d66d74cb14e3c86895789901c9135c95b16', 'hDAI', 18, 'underlying')
    ,('0xe38faf9040c7f09958c638bbdb977083722c5156', 'hETH', 18, 'underlying')
    ,('0x3666f603cc164936c1b87e207f36beba4ac5f18a', 'hUSDC', 6, 'underlying')
    ,('0xa492d3596e8391e376d4f5a5cba5c077b890b094', 'hWBTC', 8, 'underlying')
    ,('0x5da345c942cf804b306d552d343f92b69160b5df', 'HOP-LP-USDC', 18, 'receipt') --hop lp token
    ,('0x2e17b8193566345a2dd467183526dedc42d2d5a8', 'HOP-LP-USDC', 18, 'receipt')
    ,('0xf753a50fc755c6622bbcaa0f59f0522f264f006e', 'HOP-LP-USDT', 18, 'receipt')
    ,('0x22d63a26c730d49e5eab461e4f5de1d8bdf89c92', 'HOP-LP-DAI', 18, 'receipt')
    ,('0x5c2048094baade483d0b1da85c3da6200a88a849', 'HOP-LP-ETH', 18, 'receipt')
    ,('0x07ce97eb3f375901d26ec1e32144292318839802', 'HOP-LP-WBTC', 18, 'receipt')
    ,('0x60daec2fc9d2e0de0577a5c708bcadba1458a833', 'bathDAI', 18, 'receipt') --rubicon receipt token
    ,('0xb0be5d911e3bd4ee2a8706cf1fac8d767a550497', 'bathETH', 18, 'receipt')
    ,('0x7571cc9895d8e997853b1e0a1521ebd8481aa186', 'bathWBTC', 18, 'receipt')
    ,('0xe0e112e8f33d3f437d1f895cbb1a456836125952', 'bathUSDC', 18, 'receipt')
    ,('0xffbd695bf246c514110f5dae3fa88b8c2f42c411', 'bathUSDT', 18, 'receipt')
    ,('0xeb5f29afaaa3f44eca8559c3e8173003060e919f', 'bathSNX', 18, 'receipt')
    ,('0x8f69783db37905f026cf62223c9957ae0ca90a38', 'UEPC', 0, 'underlying')
    ,('0x96db852d93c2fea0f447d6ec22e146e4e09caee6', 'JPYC', 18, 'underlying')
    ,('0x8f69ee043d52161fd29137aedf63f5e70cd504d5', 'DOG', 18, 'underlying')
    ,('0x11b6b63515ab0d04a4b28a316486820cf5012ddf', 'f6-USDC', 18, 'receipt')
    ,('0x7c17611ed67d562d1f00ce82eebd39cb7b595472', 'THIRM', 18, 'underlying')
    ,('0xe0bb0d3de8c10976511e5030ca403dbf4c25165b', '0xBTC', 8, 'underlying')
    ,('0xb04095d45a98dbda07564d124b3cdb7f0d88c696', 'Demo', 18, 'underlying')
    ,('0x588abc030b08819c4c284189ce269a8fb4efe439', 'quotMKRquot', 18, 'underlying')
    ,('0xe3c332a5dce0e1d9bc2cc72a68437790570c28a4', 'VEE', 18, 'underlying')
    ,('0xb27e3eab7526bf721ea8029bfcd3fdc94c4f8b5b', 'ODOGE', 18, 'underlying')
    ,('0xdeaddeaddeaddeaddeaddeaddeaddeaddead0000', 'ETH', 18, 'underlying')
    ,('0x9bcef72be871e61ed4fbbc7630889bee758eb81d', 'rETH', 18, 'underlying')
    ,('0xc40f949f8a4e094d1b49a23ea9241d289b7b2819', 'LUSD', 18, 'underlying')
    ,('0xe88d846b69020680b2deeea58511636250c42707', 'OVM-TEST', 18, 'underlying')
    ,('0xf98dcd95217e15e05d8638da4c91125e59590b07', 'KROM', 18, 'underlying')
    ,('0xc7b04dc5a2644522a0c58c107346b5e3a63600b0', 'SACRO', 18, 'underlying')
    ,('0x7c6b91d9be155a6db01f749217d76ff02a7227f2', 'SACRO', 18, 'underlying')
    ,('0x5a5fff6f753d7c11a56a52fe47a177a87e431655', 'SYN', 18, 'underlying')
    ,('0x809dc529f07651bd43a172e8db6f4a7a0d771036', 'nETH', 18, 'underlying') --synapse swap
    ,('0x65559aa14915a70190438ef90104769e5e890a00', 'ENS', 18, 'underlying')
    ,('0x00f932f0fe257456b32deda4758922e56a4f4b42', 'PAPER', 18, 'underlying')
    ,('0x0a03498ec169247f81761d9b67bf5b206ff0c0fc', 'vBTC', 18, 'na') --perp virtual token
    ,('0x121ab82b49b2bc4c7901ca46b8277962b4350204', 'WETH', 18, 'underlying')
    ,('0x1259adc9f2a0410d0db5e226563920a2d49f4454', 'WETH', 18, 'underlying')
    ,('0x23b5b8cc1ad8ca333c817bc2e3d842e4cb90cc48', 'nETH-LP', 18, 'receipt')
    ,('0x28d8a1a6bdeaf9d42da6a55da8a34710e3434b97', 'vETH', 18, 'na') --perp virtual token
    ,('0x4619a06ddd3b8f0f951354ec5e75c09cd1cd1aef', 'nETH-LP', 18, 'receipt')
    ,('0x48a5322c3021d5ed5ce4293112141045d12c7efc', 'pWBTC', 8, 'receipt') --wepiggy
    ,('0x64b18e6d7b4693f86aa12c1724f1e195232bf044', 'vBTC', 18, 'na') --perp virtual token
    ,('0x68d97b7a961a5239b9f911da8deb57f6ef6e5e28', 'TLP', 18, 'underlying')
    ,('0x811cd5cb4cc43f44600cfa5ee3f37a402c82aec2', 'pUSDC', 8, 'receipt') --wepiggy
    ,('0xbe4a5438ad89311d8c67882175d0ffcc65dc9c03', 'BORING', 18, 'underlying')
    ,('0xc12b9d620bfcb48be3e0ccbf0ea80c717333b46f', 'pDAI', 8, 'receipt') --wepiggy
    ,('0xdb21bb0389b616bb2ebde855975df4f2ce9fb74f', 'vUSD', 18, 'na') --perp virtual token
    ,('0xe402d5eef58aad816d7240e50f20922f53a81711', 'vUSD', 18, 'na') --perp virtual token
    ,('0x5029c236320b8f15ef0a657054b84d90bfbeded3', 'bitANT', 18, 'underlying')
    ,('0xc98b98d17435aa00830c87ea02474c5007e1f272', 'bitBTC', 18, 'underlying')
    ,('0x14cd3bd06d6ea144840db5d85607492a5ae6fb38', 'Poly-Peg NB', 6, 'na') --unknown token
    ,('0x8158b34ff8a36dd9e4519d62c52913c24ad5554b', 'pUSDT', 8, 'receipt') --wepiggy
    ,('0x8a48fd91596b905e0309ba524ad5901498b325cf', 'LP-USDT', 8, 'receipt') --hop
    ,('0xa27a0a67c0ff095d19c5333be0c604d622466279', 'LP-USDC', 18, 'receipt') --hop
    ,('0x8e1e582879cb8bac6283368e8ede458b63f499a5', 'pETH', 8, 'receipt') --wepiggy
    ,('0x8f00a5e13b3f2aaaddc9708ad5c77fbcc300b0ee', 'pLINK', 8, 'receipt') --wepiggy
    ,('0x9413b54f04c90ed8eb59a08323d767b72dcd278e', 'WETH', 18, 'underlying')
    ,('0xab3f8a9599d62f09a71d7337dfff4458a4c7fe27', 'vETH', 18, 'na') --perp virtual token
    ,('0xc84da6c8ec7a57cd10b939e79eaf9d2d17834e04', 'vUSD', 18, 'na') --perp virtual token
    ,('0x8c835dfaa34e2ae61775e80ee29e2c724c6ae2bb', 'vETH', 18, 'na') --perp virtual token
    ,('0x86f1e0420c26a858fc203A3645dD1A36868F18e5', 'vBTC', 18, 'na') --perp virtual token
    ,('0x81b875688b8d134d22c52068c0cca5dcdb6cd66d', 'pKratos', 18, 'underlying')
    ,('0xa7a084538de04d808f20c785762934dd5da7b3b4', 'iETH', 18, 'receipt') --dforce borrow token
    ,('0xb344795f0e7cf65a55cb0dde1e866d46041a2cc2', 'iUSDC', 6, 'receipt') --dforce borrow token
    ,('0x5bede655e2386abc49e2cc8303da6036bf78564c', 'iDAI', 18, 'receipt') --dforce borrow token
    ,('0x30adf434dc6d586526efc3e7ea3b4550b2be7456', 'FNDR', 18, 'underlying')
    ,('0x50c5725949a6f0c72e6c4a641f24049a917db0cb', 'LYRA', 18, 'underlying')
    ,('0x89b7fda54019e62b4faf44777a0d0e85bd9c4ad3', 'Kratos', 9, 'underlying')
    ,('0xb48b36ea8dfd6113bdf7339e7ef344d0b3f9878f', 'BUZZ', 18, 'underlying')
    ,('0x1da650c3b2daa8aa9ff6f661d4156ce24d08a062', 'DCN', 0, 'underlying')
    ,('0xa807d4bc69b050b8d0c99542cf93903c2efe8b4c', 'OptiNYAN', 18, 'underlying')
    ,('0xe7798f023fc62146e8aa1b36da45fb70855a77ea', 'UMA', 18, 'underlying')
    ,('0xbfd291da8a403daaf7e5e9dc1ec0aceacd4848b9', 'USX', 18, 'underlying')
    ,('0x780f70882ff4929d1a658a4e8ec8d4316b24748a', 'vAELIN', 18, 'underlying') --Pool purchase token
    ,('0x6f620ec89b8479e97a6985792d0c64f237566746', 'WPC', 18, 'underlying')
    ,('0x6b7413c45980d506993116590b8d25e76d1ab731', 'ODOG', 18, 'underlying')
    ,('0x3e7ef8f50246f725885102e8238cbba33f276747', 'BOND', 18, 'underlying')
    ,('0x9e1028f5f1d5ede59748ffcee5532509976840e0', 'PERP', 18, 'underlying')
    ,('0x61baadcf22d2565b0f471b291c475db5555e0b76', 'AELIN', 18, 'underlying')
    ,('0x2250b4ed46b7d0a71c91da173b52555b9cc21e59', 'CHEESE', 18, 'underlying')
    ,('0xfa436399d0458dbe8ab890c3441256e3e09022a8', 'ZIP', 18, 'underlying')
    ,('0x18172f6604136041f603270790a437342b9ba57f', 'Kratos', 18, 'underlying')
    ,('0x2e3d870790dc77a83dd1d18184acc7439a53f475', 'FRAX', 18, 'underlying')
    ,('0xba6a2fa321bb06d668c5192be77428106c5c01e5', 'SOLUNAVAX', 18, 'underlying')
    ,('0xcfd1d50ce23c46d3cf6407487b2f8934e96dc8f9', 'SPANK', 18, 'underlying')
    ,('0x3390108e913824b8ead638444cc52b9abdf63798', 'MASK', 18, 'underlying')
    ,('0x217d47011b23bb961eb6d93ca9945b7501a5bb11', 'THALES', 18, 'underlying')
    ,('0x34dccfd0083259cdbc80bab5dd53234c7af2b841', 'sKratos', 9, 'underlying')
    ,('0xb54fa166d4b88b0478f299d5854ad9b94b3feff3', 'ArbiNYAN', 18, 'underlying')
    ,('0x78b1bd624791eb8aff5f0724ac2c3539142108bf', 'ZINU', 18, 'underlying')
    ,('0xaf9fe3b5ccdae78188b1f8b9a49da7ae9510f151', 'DHT', 18, 'underlying')
    ,('0xba28feb4b6a6b81e3f26f08b83a19e715c4294fd', 'UST', 6, 'underlying')
    ,('0xfb21b70922b9f6e3c6274bcd6cb1aa8a0fe20b80', 'UST', 6, 'underlying')
    ,('0x6789d8a7a7871923fc6430432a602879ecb6520a', 'vKWENTA', 18, 'underlying')
    ,('0xa279959f0a357c2c8d961056bdb74a952d44ef67', 'slPega', 18, 'underlying')
    ,('0x8b2f7ae8ca8ee8428b6d76de88326bb413db2766', 'sSOL', 18, 'underlying')
    ,('0x45c55bf488d3cb8640f12f63cbedc027e8261e79', 'SDS', 18, 'underlying')
    ,('0x333b1ea429a88d0dd48ce7c06c16609cd76f43a8', 'vSAND', 18, 'na')
    ,('0x2f198182ec54469195a4a06262a9431a42462373', 'vLINK', 18, 'na')
    ,('0x77d0cc9568605bfff32f918c8ffaa53f72901416', 'vONE', 18, 'na')
    ,('0x5f714b5347f0b5de9f9598e39840e176ce889b9c', 'vATOM', 18, 'na')
    ,('0x5faa136fc58b6136ffdaeaac320076c4865c070f', 'vAVAX', 18, 'na')
    ,('0x151bb01c79f4516c233948d69dae39869bccb737', 'vSOL', 18, 'na')
    ,('0xb24f50dd9918934ab2228be7a097411ca28f6c14', 'vLUNA', 18, 'na')
    ,('0x18607adc70d68e196d12019d49b0607b99312853', 'PEGA', 9, 'underlying')
    ,('0x67ccea5bb16181e7b4109c9c2143c24a1c2205be', 'FXS', 18, 'underlying')
    ,('0x76fb31fb4af56892a25e32cfc43de717950c9278', 'AAVE', 18, 'underlying')
    ,('0x7161c3416e08abaa5cd38e68d9a28e43a694e037', 'vCRV', 18, 'na')
    ,('0x3fb3282e3ba34a0bff94845f1800eb93cc6850d4', 'vNEAR', 18, 'na')
    ,('0x2db8d2db86ca3a4c7040e778244451776570359b', 'vFTM', 18, 'na')
    ,('0x0b5740c6b4a97f90ef2f0220651cca420b868ffb', 'gOHM', 18, 'underlying')
    ,('0x10010078a54396f62c96df8532dc2b4847d47ed3', 'HND', 18, 'underlying')
    ,('0x1f8e8472e124f58b7f0d2598eae3f4f482780b09', 'veHND', 18, 'receipt')
    ,('0x7eada83e15acd08d22ad85a1dce92e5a257acb92', 'vFLOW', 18, 'na')
    ,('0xb6599bd362120dc70d48409b8a08888807050700', 'vBNB', 18, 'na')
    ,('0xb2b42b231c68cbb0b4bf2ffebf57782fd97d3da4', 'sAVAX', 18, 'underlying')
    ,('0x81ddfac111913d3d5218dea999216323b7cd6356', 'sMATIC', 18, 'underlying')
    ,('0x00b8d5a5e1ac97cb4341c4bc4367443c8776e8d9', 'sAAVE', 18, 'underlying')
    ,('0xf5a6115aa582fd1beea22bc93b7dc7a785f60d03', 'sUNI', 18, 'underlying')
    ,('0xfbc4198702e81ae77c06d58f81b629bdf36f0a71', 'sEUR', 18, 'underlying')
    ,('0x6b5a75f38bea1ef59bc43a5d9602e77bcbe65e46', 'TCAP', 18, 'underlying')
    ,('0x296f55f8fb28e498b858d0bcda06d955b2cb3f97', 'STG', 18, 'underlying')
    ,('0xe4f27b04cc7729901876b44f4eaa5102ec150265', 'XCHF', 18, 'underlying')
    ,('0x8a466b97c6ac3379ccc3b2776d310fd4769f550e', 'STREETCRED', 18, 'underlying')
    ,('0x522439fb1da6db24f18baab1782486b55fe3a7b6', 'AVAX1X', 18, 'underlying')
    ,('0x95fffb13856d2be739a862f9b645573e5c838bdd', 'SOL1X', 18, 'underlying')
    ,('0x19f0622903a977a24bb47521732e6291002a4ede', 'LUNA1X', 18, 'underlying')
    ,('0x514832a97f0b440567055a73fe03aa160017b990', 'SOCKS', 18, 'underlying')
    ,('0x9482aafdced6b899626f465e1fa0cf1b1418d797', 'vPERP', 18, 'na')
    ,('0xbe5de48197fc974600929196239e264ecb703ee8', 'vMATIC', 18, 'na')
    ,('0x34235c8489b06482a99bb7fcab6d7c467b92d248', 'vAAVE', 18, 'na')
    ,('0x9d34f1d15c22e4c0924804e2a38cbe93dfb84bc2', 'vAPE', 18, 'na')
    ,('0xdfa46478f9e5ea86d57387849598dbfb2e964b02', 'MAI', 18, 'underlying')
    ,('0x3f56e0c36d275367b8c502090edf38289b3dea0d', 'QI', 18, 'underlying')
    ,('0x4200000000000000000000000000000000000042', 'OP', 18, 'underlying')
    ,('0xeeeeeb57642040be42185f49c52f7e9b38f8eeee', 'ELK', 18, 'underlying')
    ,('0x56613f4b8f6f3aab660dae2f80649f9f8ef381b2', 'CLC', 0, 'underlying')
    ,('0x2daba57dd495212475b438dc41c7da82ecebf155', 'CLC', 18, 'underlying')
    ,('0x0be27c140f9bdad3474beaff0a413ec7e19e9b93', 'MNYe', 18, 'underlying')
    ,('0x67c10c397dd0ba417329543c1a40eb48aaa7cd00', 'nUSD', 18, 'underlying')
    ,('0x4ac8bd1bdae47beef2d1c6aa62229509b962aa0d', 'ETHx', 18, 'receipt')
    ,('0x83ed2ee1e2744d27ffd949314f4098f13535292f', 'LOOC', 0, 'underlying')
    ,('0x0994206dfe8de6ec6920ff4d779b0d950605fb53', 'CRV', 18, 'underlying')
    ,('0x703d57164ca270b0b330a87fd159cfef1490c0a5', 'WAD', 18, 'underlying')
    ,('0x3c8b650257cfb5f272f799f5e2b4e65093a11a05', 'VELO', 18, 'underlying')
    ,('0xfe8b128ba8c78aabc59d4c64cee7ff28e9379921', 'BAL', 18, 'underlying')
    ,('0x97513e975a7fa9072c72c92d8000b0db90b163c5', 'BEETS', 18, 'underlying')
    ,('0xcb8fa9a76b8e203d8c3797bf438d8fb81ea3326a', 'alUSD', 18, 'underlying')
    ,('0x3e29d3a9316dab217754d13b28646b76607c5f04', 'alETH', 18, 'underlying')
    ,('0x8ae125e8653821e851f12a49f7765db9a9ce7384', 'DOLA', 18, 'underlying')
    ,('0x1eba7a6a72c894026cd654ac5cdcf83a46445b08', 'GTC', 18, 'underlying')
    ,('0x6bea356b8a7004f625f803b3db4d8d258c113c84', 'dcBETH', 18, 'receipt')
    ,('0x81ab7e0d570b01411fcc4afd3d50ec8c241cb74b', 'EQZ', 18, 'underlying')
    ,('0x117cfd9060525452db4a34d51c0b3b7599087f05', 'GYSR', 18, 'underlying')
    ,('0xfeaa9194f9f8c1b65429e31341a103071464907e', 'LRC', 18, 'underlying')
    ,('0xf390830DF829cf22c53c8840554B98eafC5dCBc2', 'anyUSDC', 6, 'underlying')
    ,('0x965f84d915a9efa2dd81b653e3ae736555d945f4', 'anyWETH', 18, 'underlying')
    ,('0x1ccca1ce62c62f7be95d4a67722a8fdbed6eecb4', 'Multichain alETH', 18, 'underlying')
    ,('0x922D641a426DcFFaeF11680e5358F34d97d112E1', 'anyFXS', 18, 'underlying')
    ,('0xa3A538EA5D5838dC32dde15946ccD74bDd5652fF', 'sINR', 18, 'underlying')
    ,('0xEe9801669C6138E84bD50dEB500827b776777d28', 'O3', 18, 'underlying')
    ,('0xb12c13e66AdE1F72f71834f2FC5082Db8C091358', 'ROOBEE', 18, 'underlying')
    ,('0xC22885e06cd8507c5c74a948C59af853AEd1Ea5C', 'USDD', 18, 'underlying')
    ,('0xd6909e9e702024eb93312B989ee46794c0fB1C9D', 'BICO', 18, 'underlying')
    ,('0x62BB4fc73094c83B5e952C2180B23fA7054954c4', 'PTaOptUSDC', 6, 'receipt')
    ,('0x375488F097176507e39B9653b88FDc52cDE736Bf', 'TAROT', 18, 'underlying')
    ,('0xD1917629B3E6A72E6772Aab5dBe58Eb7FA3C2F33', 'ZRX', 18, 'underlying')
    ,('0x395ae52bb17aef68c2888d941736a71dc6d4e125', 'POOL', 18, 'underlying')
    ,('0x7113370218f31764C1B6353BDF6004d86fF6B9cc', 'USDD', 18, 'underlying')
    ,('0xcB59a0A753fDB7491d5F3D794316F1adE197B21E', 'TUSD', 18, 'underlying')
    ,('0xd8f365c2c85648f9b89d9f1bf72c0ae4b1c36cfd', 'TheDAO', 18, 'underlying')
    ,('0x374Ad0f47F4ca39c78E5Cc54f1C9e426FF8f231A', 'PREMIA', 18, 'underlying')
    ,('0x6ca558bd3eaB53DA1B25aB97916dd14bf6CFEe4E', 'pETHo', 18, 'underlying')
    ,('0x00a35FD824c717879BF370E70AC6868b95870Dfb', 'IB', 18, 'underlying')
    ,('0x09448876068907827ec15F49A8F1a58C70b04d45', 'sETHo', 18, 'underlying')
    ,('0x7aE97042a4A0eB4D1eB370C34BfEC71042a056B7', 'UNLOCK', 18, 'underlying')
    ,('0xef6301da234fc7b0545c6e877d3359fe0b9e50a4', 'SUKU', 18, 'underlying')
    ,('0x676f784d19c7F1Ac6C6BeaeaaC78B02a73427852', 'OPP', 18, 'underlying')
    ,('0xe4dE4B87345815C71aa843ea4841bCdc682637bb', 'BUILD', 18, 'underlying')
    ,('0x66e8617d1Df7ab523a316a6c01D16Aa5beD93681', 'SHACK', 18, 'underlying')
    ,('0xf899e3909B4492859d44260E1de41A9E663e70F5', 'RADIO', 18, 'underlying')
    ,('0x73cb180bf0521828d8849bc8CF2B920918e23032', 'USD+', 18, 'underlying')
    ,('0xc3864f98f2a61A7cAeb95b039D031b4E2f55e0e9', 'OpenX', 18, 'underlying')
    ,('0x1DB2466d9F5e10D7090E7152B68d62703a2245F0', 'SONNE', 18, 'underlying')
    ,('0x1eC50880101022C11530A069690F5446d1464592', 'USDy', 18, 'receipt')
    ,('0x59bAbc14Dd73761e38E5bdA171b2298DC14da92d', 'dSNX', 18, 'receipt')
    ,('0x4E720DD3Ac5CFe1e1fbDE4935f386Bb1C66F4642', 'BIFI', 18, 'underlying')
    ,('0xa5974bd897B48C957CC7Cd93DB680045315d596d', 'OPrint', 18, 'underlying')
    ,('0x2513486f18eee1498d7b6281f668b955181dd0d9', 'xOpenx', 18, 'underlying')
    ,('0x39d36cF934aAE9Fcf4c5112648a016B8A7127B35', 'dETH', 18, 'underlying')
    ,('0xB153FB3d196A8eB25522705560ac152eeEc57901', 'MIM', 18, 'underlying')
    ,('0x1F32b1c2345538c0c6f582fCB022739c4A194Ebb', 'wstETH', 18, 'underlying')
    ,('0xFdb794692724153d1488CcdBE0C56c252596735F', 'LDO', 18, 'underlying')
    ,('0xd52f94df742a6f4b4c8b033369fe13a41782bf44', 'L2DAO', 18, 'underlying')
    ,('0x85f6583762bc76d775eab9a7456db344f12409f7', 'renBTC', 8, 'underlying')
    ,('0xde48b1b5853cc63b1d05e507414d3e02831722f8', 'stkLYRA', 18, 'receipt')
    ,('0x9e5aac1ba1a2e6aed6b32689dfcf62a509ca96f3', 'DF', 18, 'underlying')
    ,('0x9485aca5bbbe1667ad97c7fe7c4531a624c8b1ed', 'agEUR', 18, 'underlying')
    ,('0xAe31207aC34423C41576Ff59BFB4E036150f9cF7', 'SDL', 18, 'underlying')
    ,('0x39FdE572a18448F8139b7788099F0a0740f51205', 'OATH', 18, 'underlying')
    ,('0xc5102fE9359FD9a28f877a67E36B0F050d81a3CC', 'HOP', 18, 'underlying')
    ,('0xB0B195aEFA3650A6908f15CdaC7D92F8a5791B0B', 'BOB', 18, 'underlying')
    ,('0x86bEA60374f220dE9769b2fEf2db725bc1cDd335', 'FLASH', 18, 'underlying')
    ,('0xec6adef5e1006bb305bb1975333e8fc4071295bf', 'CTSI', 18, 'underlying')
    ,('0x0e49ca6ea763190084c846d3fc18f28bc2ac689a', 'DUCK', 18, 'underlying')
    ,('0x50bce64397c75488465253c0a034b8097fea6578', 'HAN', 18, 'underlying')
    ,('0xe3ab61371ecc88534c522922a026f2296116c109', 'SPELL', 18, 'underlying')
    ,('0x29FAF5905bfF9Cfcc7CF56a5ed91E0f091F8664B', 'BANK', 18, 'underlying')
    ,('0x920Cf626a271321C151D027030D5d08aF699456b', 'KWENTA', 18, 'underlying')
    ,('0xcdb4bb51801a1f399d4402c61bc098a72c382e65', 'OPX', 18, 'underlying')
    ,('0x479a7d1fcdd71ce0c2ed3184bfbe9d23b92e8337', 'bb-rf-aUSD-asUSD', 18, 'receipt')
    ,('0x6222ae1d2a9f6894da50aa25cb7b303497f9bebd', 'bb-rf-aUSD', 18, 'receipt')
    ,('0xc0d7013a05860271a1edb52415cf74bc85b2ace7', 'bb-rf-asUSD', 18, 'receipt')
    ,('0x7d6bff131b359da66d92f215fd4e186003bfaa42', 'BPT-USD+', 18, 'receipt')
    ,('0x75441c125890612f95b5fbf3f73db0c25f5573cd', 'rf-a-DAI', 18, 'receipt')
    ,('0xa348700745d249c3b49d2c2acac9a5ae8155f826', 'wUSD+', 6, 'receipt')
    ,('0x61cbcb4278d737471ee54dc689de50e4455978d8', 'rf-a-USDT+', 18, 'receipt')
    ,('0x9964b1bd3cc530e5c58ba564e45d45290f677be2', 'test-bb-rf-a-USD', 18, 'receipt')
    ,('0xce9329f138cd6319fcfbd8704e6ae50b6bb04f31', 'bb-rf-aDAI', 18, 'receipt')
    ,('0x15873081c0aa67ad5c5dba362169d352e2a128a2', 'bb-rf-aUSDC', 18, 'receipt')
    ,('0x43cb769d5647cc56f5c1e8df72ab9097dab59cce', 'rf-a-WBTC', 18, 'receipt')
    ,('0x0b8f31480249cc717081928b8af733f45f6915bb', 'wDAI+', 18, 'receipt')
    ,('0x7ecc9d0ee071c7b86d0ae2101231a3615564009e', 'rf-a-USDC', 18, 'receipt')
    ,('0x21f95cff4aa2e1dd8f43c6b581f246e5aa67fc9c', 'rf-grain-BAL', 18, 'receipt')
    ,('0xdf2d2c477078d2cd563648abbb913da3db247c00', 'rf-a-WETH', 18, 'receipt')
    ,('0x88d07558470484c03d3bb44c3ecc36cafcf43253', 'bb-USD+', 18, 'receipt')
    ,('0xf572649606db4743d217a2fa6e8b8eb79742c24a', 'test-bb-USD-MAI', 18, 'receipt')
    ,('0xdd89c7cd0613c1557b2daac6ae663282900204f1', 'bb-rf-aWETH', 18, 'receipt')
    ,('0x018a1e566c0847e35e7d46e4ee0428c35574a3d8', 'OD', 18, 'underlying')
    ,('0x7fe67173e14aa3349b8f24533084379e1066e19c', 'OD', 18, 'underlying')
    ,('0xa00e3a3511aac35ca78530c85007afcd31753819', 'KNC',18, 'underlying')
    ,('0x96f2539d3684dbde8b3242a51a73b66360a5b541', 'USDL', 18, 'underlying')
    ,('0x2297aebd383787a160dd0d9f71508148769342e3', 'BTC.b', 8, 'underlying')
    ,('0x3417e54a51924c225330f8770514ad5560b9098d', 'RED', 18, 'underlying')
    ,('0x6f0fecbc276de8fc69257065fe47c5a03d986394', 'POP', 18, 'underlying')
    ,('0x1a9c8b7f8695abd9a930ea49a498ce1b7a590d25', 'ABT', 18, 'underlying')
    ,('0x0c5b4c92c948691EEBf185C17eeB9c230DC019E9', 'PICKLE', 18, 'underlying')
    ,('0xB0ae108669CEB86E9E98e8fE9e40d98b867855fD', 'RING', 18, 'underlying')
    ,('0xe50fa9b3c56ffb159cb0fca61f5c9d750e8128c8', 'aOptWETH', 18, 'receipt')
    ,('0x625e7708f30ca75bfd92586e17077590c60eb4cd', 'aOptUSDC', 6, 'receipt')
    ,('0x6ab707aca953edaefbc4fd23ba73294241490620', 'aOptUSDT', 6, 'receipt')
    ,('0xf329e36c7bf6e5e86ce2150875a84ce77f477375', 'aOptAAVE', 18, 'receipt')
    ,('0x82e64f49ed5ec1bc6e43dad4fc8af9bb3a2312ee', 'aOptDAI', 18, 'receipt')
    ,('0x191c10aa4af7c30e871e70c95db0e4eb77237530', 'aOptLINK', 18, 'receipt')
    ,('0x6d80113e533a2c0fe82eabd35f1875dcea89ea97', 'aOptSUSD', 18, 'receipt')
    ,('0x078f358208685046a11c85e8ad32895ded33a249', 'aOptWBTC', 8, 'receipt')
    ,('0x513c7E3a9c69cA3e22550eF58AC1C0088e918FFf', 'aOptOP', 18, 'receipt')
    ,('0x74ccbe53F77b08632ce0CB91D3A545bF6B8E0979', 'fBOMB', 18, 'underlying')
    ,('0x9C9e5fD8bbc25984B178FdCE6117Defa39d2db39', 'BUSD', 18, 'underlying')
    ) AS temp_table (contract_address, symbol, decimals, token_type)

)

-- Pull tokens deterministically generated by contracts
, generated_tokens_list AS (
SELECT contract_address, symbol, MIN(decimals) AS decimals, token_type, token_mapping_source

FROM (

    SELECT
    LOWER(l2_token) AS contract_address, symbol AS symbol, decimals as decimals
    , 'underlying' as token_type, 'l2 token factory' AS token_mapping_source
    FROM {{ ref('ovm_optimism_l2_token_factory') }}
/*
    -- UNION ALL

    -- SELECT
    -- LOWER(atoken_address) AS contract_address, atoken_symbol AS symbol, atoken_decimals as decimals
    -- , 'receipt' as token_type, 'aave factory' AS token_mapping_source
    -- FROM {{ ('aave_v3_tokens') }} -- to be refd
    --   WHERE blockchain = 'optimism'
    
    -- UNION ALL

    -- SELECT
    -- LOWER(atoken_address) AS contract_address, atoken_symbol AS symbol, atoken_decimals as decimals
    -- , 'receipt' as token_type, 'the granary factory' AS token_mapping_source
    -- FROM {{ ('the_granary_optimism_tokens') }} -- to be refd
    --   WHERE blockchain = 'optimism'
    */
  ) a
  GROUP BY contract_address, symbol, token_type, token_mapping_source --get uniques & handle if L2 token factory gets decimals wrong
)

SELECT LOWER(contract_address) AS contract_address
      , symbol
      , decimals
      , token_type
      , token_mapping_source
      , CASE WHEN token_type IN ('underlying') THEN 1
        ELSE 0 --double counted (breakdown, receipt) or no price
      END
      AS is_counted_in_tvl

    FROM (
      SELECT contract_address, symbol, decimals, token_type, 'manual' AS token_mapping_source
        FROM raw_token_list
      UNION ALL
      SELECT contract_address, symbol, decimals, token_type, token_mapping_source
        FROM generated_tokens_list  
        WHERE contract_address NOT IN (SELECT contract_address FROM raw_token_list) -- do not duplicate if manually mapped
    ) a
