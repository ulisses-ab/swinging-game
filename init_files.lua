local function init_dirs()
    local lfs = love.filesystem

    local names = {"my_levels", "my_levels_best", "campaign_best", "campaign_levels", "campaign_stars", "campaign_thresholds"}

    for _, name in ipairs(names) do
        if not lfs.getInfo(name, "directory") then
            lfs.createDirectory(name)
        end
    end
end

local levels = {
    {
        string = [[eJyNkMtOwzAQRfd8ReV1a3k8D4+zZ8+OBUIotKYNSlPUhEdU9d9xELTpY4G98cyRR2fu7mYyMZvn1zTvWlM87HI5HPNlihmhtyKCThiIZPrHelOQOIuAFIE54BF1/Vsyhbkv69ocmp/VoluZAjB4GwRAiTjwAa9StVx1plAWiwReVH108IP307ERqPOWGMGBZ9ETIYJMOKoyqYP/CYljy16zGHmMl0IUj1jlXKhqn7bVslqY4qWs2zS2mfmgFp3mC4LRn+vcVR+b7uizLZtlbnvnpqNtc/BWNDr0TKThWh6B0YaAREEZ/YkB5KjASdCctzCfG9w2ad2bKzPdeIq7EK/LPm1//z0O1DTleiDvzfBYTNp5apK52X8DvjSCLQ==]],
        star_times = {4, 3, 2.5},
    },
    {
        string = [[eJyNUMtqwzAQvOcrgs62kFZv33sv9FhKcRO/ii0HWyU1If9eqYlVOyHQPQxodzSzs6fNdots3hUoQ325A5SERv/xWezciLLXk3+GQm1Ruvcht5VnMmow04oRSoBwnsycoanqSCKx/Y2yVBvAoAyTQnIJLM4mlHGiMVNcEg+Uqzga3VDYytUoA+Ir9t10CNu+tI2txrp3KE6+DrN5+kff90c7t4FqDAaI9CDgl3FOYsRjsw9u7N7ruc1d2Q8dWmWilDHMYi0zGXIrflV6skU3rWSo1Jhy0EIFlKvLCIkFV5Ia4vFu34eSKRMrHQbm33+FEMuvmnBML/4BH8j4+0zFcHsdAfiayuNqH4XVIvJF9G1z/gGMeo9k]],
        star_times = {4, 3, 2.2},
    },
    {
        string = [[eJyVkktvgzAQhO/5FWjPxFq/1jb33nProaoqGlygIqQC2gZF+e+FPggooSJ7snfkmU8jH1dBAGW88xDBe9kfkqDe+tJD2Cv751e/bWqIHo7dtR84QGQ0MXme8E9qIVpz64Z70771vpv8Y9/AsK3iMu3WQiGTxhI56YTSg5zXT1We5glEL3FR++/1KRzHcyctI8GlREKjJ/ECOeODpBeiaM7QclIWyVhzA4rsothME0IQo2HMQhS7uInPPGkyiBRxuoaQ+TzNmg7RoWBn00NPxh0yfknWUQsUkpmL3u7jooAZAKE1Xkk1k0wtEMc53NGY6r+YX+2u9LsWxp7K2onn2gmmJFkyaEhpO2O0KeLWVzBtRBs2/Uj85/Xj6vQFQgavpg==]],
        star_times = {8.5, 6.8, 5.8},
        threshold = 5
    },
    {
        string = [[eJyVU01vwjAMvfMrUM4QxXbiJL3vPmnHaZoYlI8JWlS6QYX470uZKIVmA3yLkzz7PT/ve/2+yD8+03G5EcnrPhzrEMViNi/fi1E2S0WiBqd0Wa3DWbwsF9lsM89L0dxUIvFgpWkSO5EwYyuxKYs0m5VzkaAK0eS/1qc6w3Nykm+zUxpVG2aZTpvGyIeKx4vDIN46KZJI4BEcMeJ9RDSxhHO0KQESSmziAXJGS/ZoWFkHBkyUKXgtSYee0WtLFOVslETtAJjIKntNPnQPjCwDX01kyJ1bPKnpWDpkJqMtortW5Hnx3VZjd8Rz0jZ4kYoIRl2XIei4pgsdALE7wBpR2ebddjGpdSXVBVyOymlerC4wh8jwryUc3OcCcG1Yg/DAsMH+MWAL0aGi4ogKxmrpWAftQx3utP2UpavqgrvxJME7FfxF5KPCIjtJTdyGDCan1oeY3zTZxyC9M9GpD8Pe8TnsbSgIsrRWNboNMdtUaXFlGqt+P7/VaZGNVvXLfDrWonf4ARlVJGA=]],
        star_times = {10.5, 9, 8},
    },
    {
        string = [[eJyVk0Fv2zAMhe/9FYXOiUBSIinmvnuBHXYYhiJr3SSD6xSJty4I+t9HD41jBduQ+WCYlP3pvUf5eHN7G7rlcxMWYfv0wGE2NLZfvzUP/T4sPh+9HK6wW3YrfylBnp1aP8NCWCKPjYOva4ax7g8vA/du82Pbh9/Nt9nxYvHTsm3D+MXr5rFfOzZbBCcpmyShcXndbFbrPiwoYzRiowxJUpkqmmdNkZNCUitYsBZXNGYhEwIsdKnoZHHiwIGYcuVwUv3T3/eX+3fg/Mx73L52pzbxOcq2eervx4jH9m6wO/bxvPO+3zXdaoiKwK+pXqJJ7XrF8qXgj+2mW+3XfxB9kmZcTdnHwZQK2HCvIiUmjVcmMvrjOl9O0UdNRQB0ykZGiYjim/pT+a9j9aFrng9huo+pxWHyxk5jqjYyyZFyEVXGIlcjGauTMfeEohbJSYXE8GoOaknREpI7VpEp0xOPWcEAmEHy1ciC4ERDTgioqfoLwDQKcEFTKX9D3rXLQ7OrmHPCaj5J8N3jl5u3XydT6uo=]],
        star_times = {32, 27, 23},
    },
    {
        string = [[eJzFlE1v2zAMhu/9FYXOqSCKEj98331ADzsMw5AtrpPBsQvHRRcU/e+Th0yxM+2QosB0E19Z5POS8svN7a3p1vvaVGbTN/2hN6sp1H/7UX8fD6b6/JK20zI/TXWH3llUAoeOWHT1RzuaKiSJko4BY1TK0nh8nC7/tG5bk4PPu824NRVAlBzb1rtmO5pKHPwOva7mqcEJW0/BkTDAIvNdVDeTMGtPj1+Hddek9BCsI3LAwKzi84lN/9zlM+Itw8QFIHQGaOuHMZ9xLseHqdwsQDnBif6+3XXNYduPZwsO41B3zeSCd2mVkFM1VgQDUxD0C2RILShpM2QtUzLNKOOVlOFdwJjRalSPURUCLsAQxIKKixARNV4DNm+BXgnG7wIWCG1EFlaOAZZgiYuZSKNXIpQS2D/mMl1KISQ0TSPO/6VjPi1LuS1LMEeaWxYunzgxXlbwsV2PD/2wN6WZRxGrHDiQpH/MIpFQOEux6CCXHVScv84rHfyr/rc5GIObDfbFY4aSg6d0H7p6fyx55eaXuILLx3o4fffl5vUXRuBbbQ==]],
        star_times = {6, 4.6, 3.6},
    },
}

local function init_levels() 
    for i, level in ipairs(levels) do
        love.filesystem.write("campaign_levels/"..i, level.string)
        love.filesystem.write("campaign_stars/"..i, level.star_times[1].." "..level.star_times[2].." "..level.star_times[3])

        if level.threshold then
            love.filesystem.write("campaign_thresholds/"..i, level.threshold)
        end
    end 
end

return function() 
    init_dirs()
    init_levels()
end