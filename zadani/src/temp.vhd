      -- "["
      --when sLeft_sq0 =>
        --nstate <= sLeft_sq1;
        --OUT_INC_PC <= '1';
        --OUT_SEL_MX1 <= '1';
        --OUT_DATA_EN <= '1';

      --when sLeft_sq1 =>
        --if IN_RDATA = x"00" then
          --nstate <= sLeft_sq2;
        --else 
          --nstate <= sFetch;
        --end if;
      
      --when sLeft_sq2 =>
          --nstate <= sLeft_sq3;
          --OUT_SEL_MX1 <= '0';
          --OUT_DATA_EN <= '1';
          --OUT_INC_PC <= '1';

      --when sLeft_sq3 =>
        --if IN_RDATA = x"5D" then
          --nstate <= sFetch;
        --else
          --nstate <= sLeft_sq2;
        --end if;

      -- "]"
      --when sRight_sq0 =>
        --nstate <= sRight_sq1;
        --OUT_SEL_MX1 <= '1';
        --OUT_DATA_EN <= '1';

      --when sRight_sq1 =>
        --if IN_RDATA /= x"00" then
          --nstate <= sRight_sq2;
        --else 
          --nstate <= sRight_sq4;
        --end if;
      
      --when sRight_sq2 =>
        --nstate <= sRight_sq3;
        --OUT_DEC_PC <= '1';
        --OUT_SEL_MX1 <= '0';
        --OUT_DATA_EN <= '1';

      --when sRight_sq3 =>
        --if IN_RDATA = x"5B" then
          --nstate <= sRight_sq4;
        --else
          --nstate <= sRight_sq2;
        --end if;

      --when sRight_sq4 =>
        --nstate <= sFetch;
        --OUT_INC_PC <= '1';