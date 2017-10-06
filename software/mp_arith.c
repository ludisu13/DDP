

/*
 * mp_arith.c
 *
 */
#include <stdint.h>
#include <stdio.h>
// Calculates res = a + b.
// a and b represent large integers stored in uint32_t arrays
// a and b are arrays of size elements, res has size+1 elements
void mp_add(uint32_t *a, uint32_t *b, uint32_t *res, uint32_t size)
{
        uint32_t l_i32carry=0;
        uint32_t i;
        uint64_t buf_res=0;
        for(i=0;i<size;i++)
        {
            buf_res = (uint64_t)a[i] + (uint64_t)b[i] + (uint64_t)l_i32carry;
            l_i32carry=buf_res >>32;
            res[i]=(uint32_t)buf_res;
        }
        res[size]=l_i32carry;

}

// Calculates res = a - b.
// a and b represent large integers stored in uint32_t arrays
// a, b and res are arrays of size elements
void mp_sub(uint32_t *a, uint32_t *b, uint32_t *res, uint32_t size)
{
    uint64_t l_i32carry=0;
    uint32_t i;
    uint64_t buf_res=0;
    for(i=0;i<size;i++)
    {
        buf_res= (uint64_t)a[i] - (uint64_t)b[i] + (uint64_t)l_i32carry;
        if (buf_res >= 0x8000000000000000)
            l_i32carry = -1;
        else
            l_i32carry = 0;
        res[i]=(uint32_t)buf_res;
    }

}

// Calculates whether a is larger than b or equal to b (result =1).
// a and b represent large integers stored in uint32_t arrays
// a, b  arrays of size elementsi
// returns result
uint32_t greater_equal(uint32_t *a, uint32_t *b, uint32_t size)
{
	uint32_t i=0;
	uint32_t result=1;//assume both arrays are equal
	for(i=size-1;i>=0;i--)
	{
		if(a[i]<b[i])
		{
			result=0;
			break;
		}
		else{
			if(a[i]>b[i]){	
				result=1;
				break;
			}
		}

	}
	return result;
}
// Calculates res = (a + b) mod N.
// a and b represent operands, N is the modulus. They are large integers stored in uint32_t arrays of size elements
void mod_add(uint32_t *a, uint32_t *b, uint32_t *N, uint32_t *res, uint32_t size)
{

	uint32_t buffer[size+1];
        mp_add(a,b,buffer,size); //find the sum of a and b. Note that the size of the sum can be 'size+1'
	
        uint32_t i=0; //some array index
        //because we will be re-using the substract module created above, we need to make 'N' the same dimension as the sum of a and b.
        uint32_t N_extended[size+1];
         //although its known that the final result will be dimension 'size', but the substract operation works on 'size+1' arrays and the result is
                                       //also an array of dimension 'size+1'
        for(i=0;i<size;i++)
                N_extended[i]=N[i];
        N_extended[size]=0; //filling the last register of N_extended with zero

        if(greater_equal(buffer,N_extended,size+1)==1)
        {
                mp_sub(buffer,N_extended,buffer,size+1);
        }
        for(i=0;i<size;i++)
                res[i]=buffer[i];
}

// Calculates res = (a - b) mod N.
// a and b represent operands, N is the modulus. They are large integers stored in uint32_t arrays of size elements
void mod_sub(uint32_t *a, uint32_t *b, uint32_t *N, uint32_t *res, uint32_t size)
{
	uint32_t buffer[32];
	if(greater_equal(a,b,size)==1)
	{
		//this means that a is greater than b
		//substract a and b
		//note that the substraction of two numbers less than N cannot be more than N!
		//so the substration of a,b must be the result of modulus substration of a and b
		mp_sub(a,b,res,size);
	}
	else
	{	mp_sub(b,a,buffer,size); //result of b-a
		mp_sub(N,buffer,res,size); //substract the result from N

	}
}

