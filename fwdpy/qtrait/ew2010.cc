/*
  Reference: www.pnas.org/cgi/doi/10.1073/pnas.0906182107
*/
#include <gsl/gsl_rng.h>
#include <gsl/gsl_randist.h>
#include <vector>
#include <map>
#include <cmath>
#include <stdexcept>
#include <algorithm>
#include <numeric>
#include <types.hpp>
#include <qtrait/qtraits.hpp>

using namespace std;

namespace fwdpy
{
  namespace qtrait
  {
    map<double,ew_mut_details> ew2010_assign_effects(GSLrng_t * rng,
						     const fwdpy::singlepop_t * pop,
						     const double tau,
						     const double sigma)
    {
      const double fourN=4.*double(pop->diploids.size());
      map<double,ew_mut_details > rv;
      for( auto itr = pop->mutations.cbegin() ; itr != pop->mutations.cend() ; ++itr )
	{
	  if(!itr->neutral)
	    {
	      if(rv.find(itr->pos) != rv.end())
		{
		  throw runtime_error("multiple mutations at same position");
		}
	      double d = (gsl_rng_uniform(rng->get()) < 0.5) ? -1. : 1.;
	      double power = pow(fourN*fabs(itr->s),tau);
	      if (itr->s < 0.) power *= -1.;
	      rv.insert(std::make_pair(itr->pos,ew_mut_details(itr->s,d*power*(1. + gsl_ran_gaussian_ziggurat(rng->get(),sigma)),2.*double(itr->n)/fourN)));
	    }
	}
      return rv;
    }
    
    //returns a list of trait values for each diploid
    vector<double> ew2010_traits_cpp(const fwdpy::singlepop_t * pop,
				     const map<double,ew_mut_details> & effects)
    {
      vector<double> rv;
      const auto sum_lambda = [&effects](const double & sum, const fwdpy::singlepop_t::gamete_t::mutation_list_type_iterator & mitr) {
	auto effects_itr = effects.find(mitr->pos);
	if(effects_itr == effects.end())
	  {
	    throw runtime_error("diploid contains a mutation at an unknown position");
	  }
	return sum + effects_itr->second.e;
      };
      for_each(pop->diploids.cbegin(),pop->diploids.cend(),[&rv,&sum_lambda]( const fwdpy::singlepop_t::diploid_t & dip )
	       {
		 double traitvalue = accumulate(dip.first->smutations.begin(),
						dip.first->smutations.end(),0.,
						sum_lambda) +
		   accumulate(dip.second->smutations.begin(),
			      dip.second->smutations.end(),0.,
			      sum_lambda);
		 rv.push_back(traitvalue);
	       });
      return rv;
    }
  }
}
