WITH unit_tests AS (

        SELECT
        CASE WHEN loans.evt_block_time = test_data.evt_block_time THEN true
                ELSE false
                END AS test_1
        ,CASE WHEN loans.borrower = test_data.borrower THEN true
                ELSE false
                END AS test_2
        ,CASE WHEN loans.lender = test_data.lender THEN true
                ELSE false
                END AS test_3
FROM {{ ref('nft_ethereum_loans') }} loans
INNER JOIN {{ ref('nft_ethereum_loans_seed') }} test_data 
        ON loans.evt_tx_hash = test_data.evt_tx_hash 
        AND loans.tokenId = test_data.tokenId 
        AND loans.collectionContract = test_data.collectionContract

)
SELECT *
FROM unit_tests
WHERE test_1 IS false
   OR test_2 IS false
   OR test_3 IS false