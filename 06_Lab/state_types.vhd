package state_types is
	type State_type is (IDLE, WRITE_A, DONE_A, READ_EK, BLOCK_P, BLOCK_I, EARLY_SAT, BLOCK_D, BLOCK_S1, BLOCK_S2, SAT_CONTROL, WRITE_B, DONE_B);
end state_types;
